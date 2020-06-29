class BillingController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhooks
  skip_before_action :authorized, only: [:webhooks]

  def create_subscription
    return unless current_user
    return if current_user.subscribed? || current_user.early_adopter?

    data = JSON.parse(request.body.read)

    unless current_user.stripe_customer_id
      stripe_customer = Stripe::Customer.create(
        metadata: {
          freshreader_account_number: current_user.account_number
        }
      )
      current_user.update(stripe_customer_id: stripe_customer.id)
    end

    payment_method_id = data['paymentMethodId']
    customer_id = current_user.stripe_customer_id

    # Attach the payment method to the customer
    begin
      Stripe::PaymentMethod.attach(
        payment_method_id,
        { customer: customer_id }
      )
    rescue Stripe::CardError => e
      return render json: { 'error': { message: e.error.message } }.to_json, status: :bad_request
    end

    # Set the default payment method on the customer
    Stripe::Customer.update(
      customer_id,
      invoice_settings: {
        default_payment_method: payment_method_id
      }
    )

    # Create the subscription
    subscription = Stripe::Subscription.create(
      customer: customer_id,
      items: [
        {
          price: FRESHREADER_PRO_MONTHLY_PRICE_ID
        }
      ],
      expand: ['latest_invoice.payment_intent']
    )

    render json: subscription.to_json
  end

  def retry_invoice
    data = JSON.parse(request.body.read)

    unless current_user.stripe_customer_id
      stripe_customer = Stripe::Customer.create(
        name: current_user.account_number
      )
      current_user.update(stripe_customer_id: stripe_customer.id)
    end

    begin
      Stripe::PaymentMethod.attach(
        data['paymentMethodId'],
        { customer: current_user.stripe_customer_id }
      )
    rescue Stripe::CardError => e
      return render json: { 'error': { message: e.error.message } }.to_json, status: :bad_request
    end

    # Set the default payment method on the customer
    Stripe::Customer.update(
      current_user.stripe_customer_id,
      invoice_settings: {
        default_payment_method: data['paymentMethodId']
      }
    )

    invoice = Stripe::Invoice.retrieve({
      id: data['invoiceId'],
      expand: ['payment_intent', 'subscription']
    })

    render json: invoice.to_json
  end

  def subscription_callback
    data = JSON.parse(request.body.read)

    # TODO: ensure subscription is active before saving it

    if current_user.stripe_customer_id == data.dig('subscription', 'customer')
      current_user.update(stripe_subscription_id: data.dig('subscription', 'id'))
    end
  end

  def cancel_subscription
    return unless current_user

    deleted_subscription = Stripe::Subscription.delete(current_user.stripe_subscription_id)

    if deleted_subscription
      current_user.update(stripe_subscription_id: nil)
      flash[:success] = 'Downgraded to Freshreader Free successfully.'
    else
      flash[:error] = 'Could not cancel subscription. Please try again, or reach out to me on Twitter (@vaillancourtmax).'
    end

    redirect_to :account
  end

  def webhooks
    # You can use webhooks to receive information about asynchronous payment events.
    # For more about our webhook events check out https://stripe.com/docs/webhooks.
    payload = request.body.read

    if !STRIPE_WEBHOOK_SECRET.empty?
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
      rescue JSON::ParserError => e
        # Invalid payload
        head 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        puts '⚠️  Webhook signature verification failed.'
        head 400
        return
      end
    else
      data = JSON.parse(payload, symbolize_names: true)
      event = Stripe::Event.construct_from(data)
    end

    event_type = event['type']

    if event_type == 'invoice.payment_succeeded'
      stripe_customer_id = JSON.parse(payload).dig('data', 'object', 'customer')

      user = User.find_by(stripe_customer_id: stripe_customer_id)
      return unless user

      user.update(stripe_subscription_id: JSON.parse(payload).dig('data', 'object', 'subscription'))
    end

    if event_type == 'invoice.payment_failed'
      stripe_customer_id = JSON.parse(payload).dig('data', 'object', 'customer')

      user = User.find_by(stripe_customer_id: stripe_customer_id)
      return unless user

      user.update(stripe_subscription_id: nil)
    end

    if event_type == 'customer.subscription.deleted'
      deleted_subscription_stripe_customer_id = JSON.parse(payload).dig('data', 'object', 'customer')

      user = User.find_by(stripe_customer_id: deleted_subscription_stripe_customer_id)
      return unless user

      user.update(stripe_subscription_id: nil)
    end

    if event_type == 'customer.deleted'
      deleted_stripe_customer_id = JSON.parse(payload).dig('data', 'object', 'id')

      user = User.find_by(stripe_customer_id: deleted_stripe_customer_id)
      return unless user

      user.update(stripe_customer_id: nil, stripe_subscription_id: nil)
    end

    render json: { status: 'success' }.to_json
  end
end

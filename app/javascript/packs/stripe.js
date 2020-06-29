const stripe_public_key = document.getElementById('stripe_public_key').dataset.attrs;

var stripe = Stripe(stripe_public_key);
var elements = stripe.elements({
  locale: 'en',
});

var style = {
  base: {
    color: "#32325d",
    fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
    fontSmoothing: "antialiased",
    fontSize: "22px",
    "::placeholder": {
      color: "#aab7c4"
    }
  },
  invalid: {
    color: "#fa755a",
    iconColor: "#fa755a"
  }
};

const user_is_on_free_plan = document.getElementById('user_is_on_free_plan').dataset.attrs == 'true';
if (user_is_on_free_plan) {
  var cardElement = elements.create("card", { style: style });
  cardElement.mount("#card-element");
  cardElement.on('change', showCardError)

  let submitButton = document.getElementById('submit-button');
  let subscriptionForm = document.getElementById('subscription-form');
  if (subscriptionForm) {
    subscriptionForm.addEventListener('submit', function (evt) {
      evt.preventDefault();

      submitButton.textContent = 'Processing...';

      // If a previous payment was attempted, get the lastest invoice
      const latestInvoicePaymentIntentStatus = localStorage.getItem(
        'latestInvoicePaymentIntentStatus'
      );

      if (latestInvoicePaymentIntentStatus === 'requires_payment_method') {
        const invoiceId = localStorage.getItem('latestInvoiceId');
        const isPaymentRetry = true;

        // Create new payment method & retry payment on invoice with new payment method
        createPaymentMethod(
          cardElement,
          isPaymentRetry,
          invoiceId
        );
      } else {
        // Create new payment method & create subscription
        createPaymentMethod(cardElement);
      }
    });
  }

  function showCardError(event) {
    submitButton.textContent = 'Upgrade';
    let displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  }

  function createPaymentMethod(cardElement, isRetry, invoiceId) {
    return stripe
      .createPaymentMethod({
        type: 'card',
        card: cardElement,
      })
      .then((result) => {
        if (result.error) {
          showCardError(result.error);
        } else {
          if (isRetry) {
            retryInvoiceWithNewPaymentMethod({
              paymentMethodId: result.paymentMethod.id,
              invoiceId,
            });
          } else {
            createSubscription(result.paymentMethod.id);
          }
        }
      });
  }

  function clearCache() {
    localStorage.clear();
  }

  function onSubscriptionComplete(result) {
    clearCache();

    let subscription = result.subscription || invoice.subscription;

    if (subscription) {
      if (subscription.status === 'active') {
        fetch('/subscription_callback', {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          },
          body: JSON.stringify({
            subscription: subscription,
          }),
        })
          .then((response) => {
            window.location = '/account?subscription_complete=true'
          })
      } else if (subscription.status === 'incomplete') {
        window.location = '/account?subscription_complete=false'
      }
    } else {
      throw "Expected subscription, didn't receive any."
    }
  }

  function handleCustomerActionRequired({
    subscription,
    invoice,
    priceId,
    paymentMethodId,
    isRetry,
  }) {
    if (subscription && subscription.status === 'active') {
      // Subscription is active, no customer actions required.
      return { subscription, priceId, paymentMethodId };
    }

    // If it's a first payment attempt, the payment intent is on the subscription latest invoice.
    // If it's a retry, the payment intent will be on the invoice itself.
    let paymentIntent = invoice ? invoice.payment_intent : subscription.latest_invoice.payment_intent;

    if (
      paymentIntent.status === 'requires_action' ||
      (isRetry === true && paymentIntent.status === 'requires_payment_method')
    ) {
      return stripe
        .confirmCardPayment(paymentIntent.client_secret, {
          payment_method: paymentMethodId,
        })
        .then((result) => {
          if (result.error) {
            throw result;
          } else {
            if (result.paymentIntent.status === 'succeeded') {
              return {
                priceId: priceId,
                subscription: subscription,
                invoice: invoice,
                paymentMethodId: paymentMethodId,
              };
            }
          }
        })
        .catch((error) => {
          showCardError(error);
        });
    } else {
      return { invoice, subscription, priceId, paymentMethodId };
    }
  }

  function handlePaymentMethodRequired({
    subscription,
    paymentMethodId,
    priceId,
  }) {
    if (subscription.status === 'active') {
      // subscription is active, no customer actions required.
      return { subscription, priceId, paymentMethodId };
    } else if (
      subscription.latest_invoice.payment_intent.status ===
      'requires_payment_method'
    ) {
      localStorage.setItem('latestInvoiceId', subscription.latest_invoice.id);
      localStorage.setItem(
        'latestInvoicePaymentIntentStatus',
        subscription.latest_invoice.payment_intent.status
      );
      throw { error: { message: 'Your card was declined.' } };
    } else {
      return { subscription, priceId, paymentMethodId };
    }
  }

  function retryInvoiceWithNewPaymentMethod({
    customerId,
    paymentMethodId,
    invoiceId,
    priceId
  }) {
    return (
      fetch('/retry_invoice', {
        method: 'post',
        headers: {
          'Content-type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        },
        body: JSON.stringify({
          customerId: customerId,
          paymentMethodId: paymentMethodId,
          invoiceId: invoiceId,
        }),
      })
        .then((response) => {
          return response.json();
        })
        .then((result) => {
          if (result.error) {
            throw result;
          }
          return result;
        })
        .then((result) => {
          return {
            invoice: result,
            paymentMethodId: paymentMethodId,
            priceId: priceId,
            isRetry: true,
          };
        })
        .then(handleCustomerActionRequired)
        .then(onSubscriptionComplete)
        .catch((error) => {
          if (error) showCardError(error);
        })
    );
  }

  function createSubscription(paymentMethodId) {
    return (
      fetch('/create_subscription', {
        method: 'post',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        },
        body: JSON.stringify({
          paymentMethodId: paymentMethodId,
        }),
      })
        .then((response) => {
          return response.json();
        })
        .then((result) => {
          if (result.error) {
            throw result;
          }
          return result;
        })
        .then((result) => {
          return {
            paymentMethodId: paymentMethodId,
            priceId: result.plan.id,
            subscription: result,
          };
        })
        .then(handleCustomerActionRequired)
        .then(handlePaymentMethodRequired)
        .then(onSubscriptionComplete)
        .catch((error) => {
          if (error) showCardError(error);
        })
    );
  }
}
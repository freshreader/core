class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def show
    if params.key?('subscription_complete')
      subscription_complete = params['subscription_complete']

      if subscription_complete == 'true'
        flash[:success] = 'Welcome to Freshreader Pro! Thank you for your support. Enjoy! ❤️'
        redirect_to :articles
      elsif subscription_complete == 'false'
        10.times do
          if current_user.reload.subscribed?
            flash[:success] = 'Welcome to Freshreader Pro! Thank you for your support. Enjoy! ❤️'
            return redirect_to :account
          end
          sleep(1)
        end

        flash[:info] = 'The payment method is taking a while to process, refresh in a few minutes.'
        return redirect_to :account
      end
    end
    @user = current_user
  end

  def create
    @user = User.new(account_number: User.generate_account_number)

    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Account created successfully."
      redirect_to :account
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      redirect_to :login
    end
  end

  def destroy
    user = current_user
    return unless user

    if user.subscribed?
      Stripe::Subscription.delete(user.stripe_subscription_id)
    end

    if user.destroy
      flash[:success] = 'Account deleted successfully.'
    else
      flash[:error] = 'There was an issue deleting your account.'
    end
    redirect_to :index
  end
end

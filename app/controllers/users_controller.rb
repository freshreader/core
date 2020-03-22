class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def show
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
    if user.destroy
      flash[:success] = 'Account deleted successfully.'
    else
      flash[:error] = 'There was an issue deleting your account.'
    end
    redirect_to :index
  end
end

class UsersController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def new
  end

  def create
    @user = User.new(account_number: User.generate_account_number)

    if @user.save
      session[:user_id] = @user.id
      redirect_to :articles
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      redirect_to :login
    end
  end
end

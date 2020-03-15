class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def new
    @user = User.new
    render :login
  end

  def create
    if @user = User.find_by(account_number: params[:account_number])
      session[:user_id] = @user.id
      redirect_to :articles
    else
      redirect_to :login, flash: { error: 'invalid account number' }
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to :login
  end
end

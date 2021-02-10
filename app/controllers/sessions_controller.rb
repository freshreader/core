class SessionsController < ApplicationController
  skip_before_action :authorized, only: [:new, :create]

  def new
    return redirect_to :articles if logged_in?

    @user = User.new
    render :login
  end

  def create
    if @user = User.find_by(account_number: params[:account_number].delete(' '))
      session[:user_id] = @user.id
      if params[:return_to].present?
        redirect_to params[:return_to]
      else
        redirect_to :articles
      end
    else
      redirect_to :login, flash: { error: "This account number does not exist." }
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end
end

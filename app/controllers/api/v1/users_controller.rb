class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate, only: [:show, :create]

  def show
    user = User.find_by(account_number: params[:account_number])

    if user
      user.regenerate_api_auth_token_if_expired!
      render json: user
    else
      render json: {}, status: :not_found
    end
  end

  def create
    user = User.new(
      account_number: User.generate_account_number,
      api_auth_token: User.generate_api_auth_token,
      api_auth_token_expires_at: Time.now + 30.second,
    )

    if user.save
      render json: user, status: :created
    else
      render json: user.errors, status: :internal_server_error
    end
  end

  def destroy
    user = current_user
    if user.destroy
      head :no_content
    else
      render json: user.errors, status: :internal_server_error
    end
  end
end


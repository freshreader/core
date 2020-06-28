module Api
  module V1
    class BaseController < ActionController::Base
      before_action :authenticate
      protect_from_forgery with: :null_session

      private

      def authenticate
        authenticate_or_request_with_http_token do |provided_token, options|
          return unless (user = User.find_by(account_number: options[:account_number]))

          if valid_auth_token?(user, provided_token)
            user
          else
            # Maybe the auth token is expired, let's generate a new one for clients to use
            user.regenerate_api_auth_token_if_expired!
            false
          end
        end
      end

      def valid_auth_token?(user, provided_token)
        user &&
          user.api_auth_token_expires_at > Time.now &&
          ActiveSupport::SecurityUtils.secure_compare(user.api_auth_token, provided_token)
      end

      def current_user
        @current_user ||= authenticate
      end
    end
  end
end

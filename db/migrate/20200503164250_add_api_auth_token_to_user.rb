class AddApiAuthTokenToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :api_auth_token, :string
    add_column :users, :api_auth_token_expires_at, :datetime
  end
end

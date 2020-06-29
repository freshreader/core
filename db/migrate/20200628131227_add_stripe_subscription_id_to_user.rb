class AddStripeSubscriptionIdToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :stripe_subscription_id, null: true
    end
  end
end

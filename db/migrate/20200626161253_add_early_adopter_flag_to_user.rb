class AddEarlyAdopterFlagToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.boolean :is_early_adopter, null: false, default: false
    end
  end
end

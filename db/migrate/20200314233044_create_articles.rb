class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.text :url
      t.timestamps
    end

    add_reference :articles, :user, foreign_key: true
  end
end

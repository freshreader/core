class AddTitleToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :title, :text
  end
end

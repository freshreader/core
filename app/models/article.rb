class Article < ApplicationRecord
  belongs_to :user
  validates :url, presence: true, url: true

  include ActiveModel::Serializers::JSON

  def attributes
    {
      'id' => id,
      'title' => title,
      'url' => url,
      'created_at' => created_at,
    }
  end
end

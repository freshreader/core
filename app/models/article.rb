class Article < ApplicationRecord
  ARTICLES_LIMIT_ON_FREE_PLAN = 10

  belongs_to :user
  validates :url, presence: true, url: true

  default_scope { order(updated_at: :desc) }

  include ActiveModel::Serializers::JSON

  def attributes
    {
      'id' => id,
      'title' => title,
      'url' => url,
      'created_at' => created_at,
    }
  end

  def age_in_days
    ((Time.now.utc - self.created_at) / 1.day).round
  end
end

class Article < ApplicationRecord
  belongs_to :user
  validates :url, presence: true, url: true
end

class Article < ApplicationRecord
  belongs_to :user
  validates :url, presence: true, url: true

  def self.title_from_url(url)
    title_from_response_body(Net::HTTP.get(URI(url)))
  end

  def self.title_from_response_body(body)
    title = body&.match(/<title>(.*?)<\/title>/m)&.[](1)&.strip&.force_encoding('UTF-8')
    HTMLEntities.new.decode(title) if title
  end
end

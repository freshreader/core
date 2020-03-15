require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    @user = User.new(account_number: User.generate_account_number)
  end

  test 'article is valid' do
    article = Article.new(url: 'https://freshreader.app/', user: @user)
    assert article.valid?
  end

  test 'article is invalid without invalid URL' do
    article = Article.new(url: 'not-an-url', user: @user)
    refute article.valid?
    assert_equal ["is not a valid URL"], article.errors[:url]
  end

  test 'article is invalid with nil user' do
    article = Article.new(url: 'https://freshreader.app/', user: nil)
    refute article.valid?
    assert_equal ['must exist'], article.errors[:user]
  end

  test 'article is invalid without user' do
    article = Article.new(url: 'https://freshreader.app/')
    refute article.valid?
    assert_equal ['must exist'], article.errors[:user]
  end
end

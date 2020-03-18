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

  test 'article is valid with title' do
    article = Article.new(url: 'https://freshreader.app/', title: 'Freshreader', user: @user)
    assert article.valid?
  end

  test 'article is valid with nil title' do
    article = Article.new(url: 'https://freshreader.app/', title: nil, user: @user)
    assert article.valid?
  end

  test 'article is valid with empty title' do
    article = Article.new(url: 'https://freshreader.app/', title: '', user: @user)
    assert article.valid?
  end

  test '.title_from_response_body parses non-utf8 characters' do
    expected = '«Nous devons agir maintenant», dit Theresa Tam'
    actual = Article.title_from_response_body("<title>\xC2\xABNous devons agir maintenant\xC2\xBB, dit Theresa Tam</title>")
    assert_equal expected, actual

    expected = 'Why I still use a ThinkPad X220 in 2019 — Maxime Vaillancourt'
    actual = Article.title_from_response_body("<title>\n    \n      Why I still use a ThinkPad X220 in 2019 &mdash; Maxime Vaillancourt\n    \n  </title>")
    assert_equal expected, actual

    expected = 'Foobar'
    actual = Article.title_from_response_body("<title data-enabled=\"true\">Foobar</title>")
    assert_equal expected, actual
  end
end

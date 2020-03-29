class ArticlesControllerTest < ActionDispatch::IntegrationTest
  def test_get_articles_when_logged_out_redirects_to_login
    get(articles_url)
    assert_redirected_to(:login)
  end

  def test_get_articles_when_logged_in
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    get(articles_url)
    assert_response(:success)
    assert_includes(response.body, 'Save new URL')
  end

  def test_save_invalid_url_redirects_to_articles
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    assert_no_difference('Article.count') do
      post(articles_url, params: { article: { url: 'http' } })
      assert_redirected_to(:articles)
    end
  end

  def test_save_empty_url_redirects_to_articles
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    assert_no_difference('Article.count') do
      post(articles_url, params: { article: { url: '  ' } })
      assert_redirected_to(:articles)
    end
  end

  def test_save_valid_url_succeeds
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    assert_difference('Article.count') do
      post(articles_url, params: { article: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019' } })
      assert_redirected_to(:articles)
    end
  end

  def test_save_valid_url_from_bookmarklet_succeeds
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    assert_difference('Article.count') do
      get(save_bookmarklet_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019' })
    end
  end

  def test_save_valid_url_from_bookmarklet_without_logged_in_user_fails
    user = User.new(account_number: '1234123412341234')
    user.save

    assert_no_difference('Article.count') do
      get(save_bookmarklet_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019' })
      assert_equal 302, response.status
    end
  end

  def test_save_valid_url_from_mobile_succeeds
    user = User.new(account_number: '1234123412341234')
    user.save

    assert_difference('Article.count') do
      get(save_mobile_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019', account_number: '1234123412341234' })
      assert_equal 200, response.status
    end
  end

  def test_save_valid_url_from_mobile_with_invalid_user_fails
    user = User.new(account_number: '1234123412341234')
    user.save

    assert_no_difference('Article.count') do
      get(save_mobile_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019', account_number: '5555' })
      assert_equal 401, response.status
    end
  end

  def test_save_valid_url_from_mobile_with_invalid_url_fails
    user = User.new(account_number: '1234123412341234')
    user.save

    assert_no_difference('Article.count') do
      get(save_mobile_url, params: { url: 'not-a-valid-url', account_number: '1234123412341234' })
      assert_equal 500, response.status
    end
  end

  def test_delete_existing_article_succeeds
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    inserted_article = assert_difference('Article.count', 1) do
      post(articles_url, params: { article: { url: 'https://example.com/' } })
      assert_redirected_to(:articles)
      Article.last
    end

    assert_difference('Article.count', -1) do
      delete(article_url(inserted_article))
      assert_redirected_to(:articles)
    end
  end
end

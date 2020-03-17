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
    assert_includes(response.body, 'URL to save')
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
end

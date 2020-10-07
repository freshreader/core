class ArticlesControllerTest < ActionDispatch::IntegrationTest
  def test_get_articles_when_logged_out_redirects_to_login
    get(articles_url)
    assert_redirected_to(:login)
  end

  def test_get_articles_when_logged_in
    user = create_user(account_number: '1234123412341234')
    post(login_url, params: { account_number: user.account_number })

    get(articles_url)
    assert_response(:success)
    assert_includes(response.body, 'Save new URL')
  end

  def test_save_invalid_url_redirects_to_articles
    user = create_user(account_number: '1234123412341234')
    post(login_url, params: { account_number: user.account_number })

    assert_no_difference('Article.count') do
      post(articles_url, params: { article: { url: 'http' } })
      assert_redirected_to(:articles)
    end
  end

  def test_save_empty_url_redirects_to_articles
    user = create_user(account_number: '1234123412341234')
    post(login_url, params: { account_number: user.account_number })

    assert_no_difference('Article.count') do
      post(articles_url, params: { article: { url: '  ' } })
      assert_redirected_to(:articles)
    end
  end

  def test_save_valid_url_succeeds
    user = create_user(account_number: '1234123412341234')
    post(login_url, params: { account_number: user.account_number })

    assert_difference('Article.count') do
      post(articles_url, params: { article: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019' } })
      assert_redirected_to(:articles)
    end
  end

  def test_save_more_than_5_articles_on_free_plan_fails
    user = create_user(account_number: '6789678967896789', is_subscribed: false)
    User.find_by(account_number: '6789678967896789').articles.destroy_all

    post(login_url, params: { account_number: user.account_number })

    assert_difference('Article.count', +Article::ARTICLES_LIMIT_ON_FREE_PLAN) do
      Article::ARTICLES_LIMIT_ON_FREE_PLAN.times do
        post(articles_url, params: { article: { url: 'https://maximevaillancourt.com/blog/why-i-use-a-thinkpad-x220-in-2019' } })
        assert_redirected_to(:articles)
      end
    end

    assert_no_difference('Article.count') do
      post(articles_url, params: { article: { url: 'https://maximevaillancourt.com/blog/why-i-use-a-thinkpad-x220-in-2019' } })
      assert_includes flash[:warning], "You cannot save more than #{Article::ARTICLES_LIMIT_ON_FREE_PLAN} items"
      assert_redirected_to(:articles)
    end
  end

  def test_save_valid_url_from_bookmarklet_succeeds
    user = create_user(account_number: '1234123412341234')
    post(login_url, params: { account_number: user.account_number })

    assert_difference('Article.count') do
      get(save_bookmarklet_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019' })
    end
  end

  def test_save_valid_url_from_bookmarklet_without_logged_in_user_fails
    user = create_user(account_number: '1234123412341234')

    assert_no_difference('Article.count') do
      get(save_bookmarklet_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019' })
      assert_equal 302, response.status
    end
  end

  def test_save_valid_url_from_mobile_succeeds
    user = create_user(account_number: '1234123412341234')

    assert_difference('Article.count') do
      get(save_mobile_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019', account_number: '1234123412341234' })
      assert_equal 200, response.status
    end
  end

  def test_save_valid_url_from_mobile_with_invalid_user_fails
    user = create_user(account_number: '1234123412341234')

    assert_no_difference('Article.count') do
      get(save_mobile_url, params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019', account_number: '5555' })
      assert_equal 401, response.status
    end
  end

  def test_save_valid_url_from_mobile_with_invalid_url_fails
    user = create_user(account_number: '1234123412341234')

    assert_no_difference('Article.count') do
      get(save_mobile_url, params: { url: 'not-a-valid-url', account_number: '1234123412341234' })
      assert_equal 500, response.status
    end
  end

  def test_delete_existing_article_succeeds
    user = create_user(account_number: '1234123412341234')
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

  def test_delete_existing_article_from_another_user_fails
    user1 = create_user(account_number: '1234123412341234')

    post(login_url, params: { account_number: user1.account_number })

    inserted_article = assert_difference('Article.count', 1) do
      post(articles_url, params: { article: { url: 'https://example.com/' } })
      assert_redirected_to(:articles)
      Article.last
    end

    user2 = create_user(account_number: '2234123412341234')

    post(login_url, params: { account_number: user2.account_number })

    assert_difference('Article.count', 0) do
      delete(article_url(inserted_article))
      assert_redirected_to(:articles)
    end
  end

  def test_save_article_when_logged_out_redirects_to_login_then_saves
    user = create_user(account_number: '1234123412341234')

    assert_no_difference('Article.count') do
      get(save_bookmarklet_url, params: { url: 'https://freshreader.app' })
      assert_redirected_to("http://www.example.com/login?return_to=#{CGI.escape('http://www.example.com/save?url=https://freshreader.app')}")
    end

    assert_difference('Article.count', 1) do
      post(login_url, params: {
        account_number: user.account_number,
        return_to: '/save?url=https://freshreader.app'
      })
      assert_redirected_to('http://www.example.com/save?url=https://freshreader.app')
      get('http://www.example.com/save?url=https://freshreader.app')
    end
  end

  def test_save_already_existing_acticle_will_only_update
    user = create_user(account_number: '1234123412341234')
    post(login_url, params: { account_number: user.account_number })
    post(articles_url, params: { article: { url: 'https://android-js.github.io' } })

    inserted_article = Article.last

    updated_article = assert_no_difference('Article.count') do
      post(articles_url, params: { article: { url: 'https://android-js.github.io' } })
      assert_redirected_to(:articles)
      Article.last
    end
    assert_not_equal(inserted_article.updated_at, updated_article.updated_at)
  end

  private

  def create_user(account_number:, is_subscribed: true, is_early_adopter: false)
    user = User.new(
      account_number: account_number,
      stripe_customer_id: "stripe_cus_1234",
      stripe_subscription_id: is_subscribed ? "stripe_sub_1234" : nil,
      is_early_adopter: is_early_adopter,
    )
    user.save
    user
  end
end

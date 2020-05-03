class ArticlesControllerTest < ActionDispatch::IntegrationTest
	setup do
    @user = create_user
    @credentials = authenticate(@user.api_auth_token, @user.account_number)
	end

  teardown do
    User.destroy_all
  end

  def test_get_articles_without_authentication_returns_401
    get "/api/v1/articles"
    assert_response(:unauthorized)
    assert_equal('HTTP Token: Access denied.', response.body.strip)
  end

  def test_get_articles_when_authenticated
    get "/api/v1/articles", headers: { "Authorization" => @credentials }
    assert_response(:success)
    assert_equal([], JSON.parse(response.body))
  end

  def test_insert_article_then_get_all_articles_when_authenticated
    get "/api/v1/articles", headers: { "Authorization" => @credentials }
    assert_response(:success)
    assert_equal([], JSON.parse(response.body))

    post(
      '/api/v1/articles',
      params: { url: 'https://example.com/' },
      headers: { "Authorization" => @credentials },
    )
    assert_response(:created)

    get "/api/v1/articles", headers: { "Authorization" => @credentials }
    assert_response(:success)

    articles = JSON.parse(response.body)
    assert_equal(1, articles.size)

    saved_article = articles.first
    assert_equal(['id', 'title', 'url', 'created_at'], saved_article.keys)
    assert_equal('Example Domain', saved_article['title'])
    assert_equal('https://example.com/', saved_article['url'])
  end

  def test_save_invalid_url_returns_422
    assert_no_difference('Article.count') do
      post('/api/v1/articles', params: { article: { url: 'http' } }, headers: { "Authorization" => @credentials })
      assert_response(:unprocessable_entity)
    end
  end

  def test_save_empty_url_returns_422
    assert_no_difference('Article.count') do
      post('/api/v1/articles', params: { article: { url: '     ' } }, headers: { "Authorization" => @credentials })
      assert_response(:unprocessable_entity)
    end
  end

  def test_save_valid_url_succeeds
    assert_difference('Article.count') do
      post(
        '/api/v1/articles',
        params: { url: 'https://maximevaillancourt.com/why-i-use-a-thinkpad-x220-in-2019'},
        headers: { "Authorization" => @credentials },
      )
      assert_response(:created)
    end
  end

  def test_delete_existing_article_succeeds
    inserted_article = assert_difference('Article.count', 1) do
      post(
        '/api/v1/articles',
        params: { url: 'https://example.com/' },
        headers: { "Authorization" => @credentials },
      )
      assert_response(:created)
      Article.last
    end

    assert_equal(1, Article.count)

    assert_difference('Article.count', -1) do
      delete(
        "/api/v1/articles/#{inserted_article.id}",
        headers: { "Authorization" => @credentials },
      )
      assert_response(:no_content)
    end

    assert_equal(0, Article.count)
  end

	private

  def authenticate(token, account_number)
    ActionController::HttpAuthentication::Token.encode_credentials(token, account_number: account_number)
  end

  def create_user
    user = User.new(
      account_number: '1234123412341234',
      api_auth_token: '12345',
      api_auth_token_expires_at: Time.now + 10.minute
    )
    user.save
    user
  end
end

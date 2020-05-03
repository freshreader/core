class UsersControllerTest < ActionDispatch::IntegrationTest
	setup do
    @user = create_user
    @credentials = authenticate(@user.api_auth_token, @user.account_number)
	end

  teardown do
    User.destroy_all
  end

  def test_get_non_existing_user
    get "/api/v1/users/0001234"
    assert_response(:not_found)
    assert_equal({}, JSON.parse(response.body))
  end

  def test_get_existing_user
    get "/api/v1/users/#{@user.account_number}"
    assert_response(:success)
    user_json = JSON.parse(response.body)
    assert_equal(@user.account_number, user_json['account_number'])
  end

  def test_create_user_succeeds
    assert_difference('User.count', 1) do
      post "/api/v1/users/"
      assert_response(:created)
      user_json = JSON.parse(response.body)
      assert_equal(['id', 'account_number', 'api_auth_token'], user_json.keys)
      assert_not_equal('', user_json['id'])
      assert_not_equal('', user_json['account_number'])
      assert_not_equal('', user_json['api_auth_token'])
    end
  end

  def test_delete_account_succeeds
    other_user = User.new(
      account_number: '7777666655554444',
      api_auth_token: '11111',
      api_auth_token_expires_at: Time.now + 10.minute
    )
    other_user.save

    assert_equal(2, User.count)

    delete(
      "/api/v1/users",
      headers: { "Authorization" => @credentials },
    )
    assert_response(:no_content)

    assert_equal(1, User.count)

    assert_includes(User.all, other_user)
    refute_includes(User.all, @user)
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

class HomeControllerTest < ActionDispatch::IntegrationTest
  def test_logged_out_home
    get('/')

    assert_includes(response.body, 'hi! Freshreader is a web-based service where you can add articles to read later.')
    refute_includes(response.body, 'You are logged in, my friend. Your list of saved articles is available here:')
    assert_response(:success)
  end

  def test_logged_in_home
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    get('/')

    assert_includes(response.body, 'hi! Freshreader is a web-based service where you can add articles to read later.')
    assert_includes(response.body, 'You are logged in, my friend. Your list of saved articles is available here:')
    assert_response(:success)
  end
end

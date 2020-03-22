class HomeControllerTest < ActionDispatch::IntegrationTest
  def test_logged_out_home
    get('/')

    assert_includes(response.body, 'Log in')
    refute_includes(response.body, 'View list')
    assert_response(:success)
  end

  def test_logged_in_home
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    get('/')

    assert_includes(response.body, 'View list')
    refute_includes(response.body, 'Log in')
    assert_response(:success)
  end
end

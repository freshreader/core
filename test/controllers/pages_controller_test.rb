class PagesControllerTest < ActionDispatch::IntegrationTest
  def test_logged_out_index
    get('/')

    assert_includes(response.body, 'Log in')
    refute_includes(response.body, 'View list')
    assert_response(:success)
  end

  def test_logged_in_index
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    get('/')

    assert_includes(response.body, 'Reading list')
    refute_includes(response.body, 'Log in')
    assert_response(:success)
  end

  def test_privacy_page
    get('/privacy')
    assert_includes(response.body, 'A few words on privacy')
    assert_response(:success)
  end
end

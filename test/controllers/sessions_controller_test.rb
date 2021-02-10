class SessionsControllerTest < ActionDispatch::IntegrationTest
  def test_login_succeeds_with_valid_account_number
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: user.account_number })

    assert_redirected_to(:articles)
  end

  def test_login_succeeds_with_whitespaced_valid_account_number
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: '  1234 123 4 1234 1234   ' })

    assert_redirected_to(:articles)
  end

  def test_login_succeeds_with_valid_account_number_and_empty_return_to_param
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { return_to: '  ', account_number: user.account_number })

    assert_redirected_to(:articles)
  end

  def test_login_fails_with_non_existent_account_number
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: 789 })

    assert_redirected_to(:login)
    assert_equal 'This account number does not exist.', flash[:error]
  end

  def test_login_fails_with_empty_account_number
    user = User.new(account_number: '1234123412341234')
    user.save
    post(login_url, params: { account_number: '' })

    assert_redirected_to(:login)
    assert_equal 'This account number does not exist.', flash[:error]
  end
end

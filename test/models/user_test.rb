require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user is valid' do
    user = User.new(account_number: User.generate_account_number)
    assert user.valid?
  end

  test 'user is valid with integer account_number' do
    user = User.new(account_number: 123)
    refute user.valid?
    assert_equal ['is invalid'], user.errors[:account_number]
  end

  test 'user is invalid with invalid account_number type' do
    user = User.new(account_number: {})
    refute user.valid?
    assert_equal ['is invalid'], user.errors[:account_number]
  end

  test 'user is invalid with nil account_number' do
    user = User.new(account_number: nil)
    refute user.valid?
    assert_equal ["can't be blank", 'is invalid'], user.errors[:account_number]
  end

  test 'user is invalid without account_number' do
    user = User.new
    refute user.valid?
    assert_equal ["can't be blank", 'is invalid'], user.errors[:account_number]
  end

  test 'by default, a new user is not considered as an early adopter' do
    user = User.new(account_number: User.generate_account_number)
    user.save

    refute user.early_adopter?
  end
end

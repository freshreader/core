require 'securerandom'

class User < ApplicationRecord
  has_many :articles, dependent: :destroy
  validates :account_number, uniqueness: true, presence: true
  validates_format_of :account_number, :with => /\A\d{16}\z/

  include ActiveModel::Serializers::JSON

  def attributes
    {
      'id' => id,
      'account_number' => account_number,
      'api_auth_token' => api_auth_token,
    }
  end

  def early_adopter?
    is_early_adopter?
  end

  def pretty_account_number
    account_number.chars.each_slice(4).map(&:join).join(' ')
  end

  def self.generate_account_number
    new_account_number = generate_16_digit_number

    while find_by(account_number: new_account_number)
      new_account_number = generate_16_digit_number
    end

    new_account_number
  end

  def self.generate_api_auth_token
    loop do
      token = SecureRandom.hex(32)
      break token unless User.where(api_auth_token: token).exists?
    end
  end

  def regenerate_api_auth_token_if_expired!
    return if api_auth_token.present? && api_auth_token_expires_at > Time.now
    self.api_auth_token = User.generate_api_auth_token
    self.api_auth_token_expires_at = Time.now + 1.day
    self.save
  end

  private_class_method def self.generate_16_digit_number
    SecureRandom.random_number(10**16).to_s.rjust(16, '0')
  end
end

require 'securerandom'

class User < ApplicationRecord
  has_many :articles, dependent: :destroy
  validates :account_number, uniqueness: true, presence: true
  validates_format_of :account_number, :with => /\A\d{16}\z/

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

  private_class_method def self.generate_16_digit_number
    SecureRandom.random_number(10**16).to_s.rjust(16, '0')
  end
end

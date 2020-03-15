require 'securerandom'

class User < ApplicationRecord
  has_many :articles, dependent: :destroy
  validates :account_number, uniqueness: true, presence: true

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

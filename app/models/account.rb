class Account < ApplicationRecord
  belongs_to :customer
  has_many :account_transactions

  validates :account_number, presence: true
  validates :balance, presence: true, numericality: true
end

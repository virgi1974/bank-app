class AccountTransaction < ApplicationRecord
  belongs_to :account

  TRANSACTION_TYPES = ["INTERNAL", "EXTERNAL"].freeze
  STATUS_TYPES = ["OK", "KO", "PENDING"].freeze

  validates :related_account, presence: true
  validates :transaction_type, presence: true
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES }
  validates :status, presence: true
  validates :status, inclusion: { in: STATUS_TYPES }
  validates :transefered_amount, presence: true, numericality: true
end

class BankCondition < ApplicationRecord
  belongs_to :bank

  TRANSACTION_TYPES = ['INTERNAL', 'EXTERNAL'].freeze

  validates :external_bank_number, presence: true
  validates :commission, presence: true, numericality: true
  validates :max_amount, presence: true, numericality: true
  validates :min_amount, presence: true, numericality: true
  validates :transaction_type, presence: true
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES }
end

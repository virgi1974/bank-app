class AccountTransaction < ApplicationRecord
  belongs_to :account

  TRANSACTION_TYPES = ['INTERNAL', 'EXTERNAL'].freeze
  STATUS_TYPES = ['OK', 'KO', 'PENDING'].freeze

  validates :bank_to_account, presence: true
  validates :transaction_type, presence: true
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES }
  validates :status, presence: true
  validates :status, inclusion: { in: STATUS_TYPES }
  validates :transefered_amount, presence: true, numericality: true

  def update_as_ok
    self.status = 'OK'
    self.save
  end

  def update_as_ko
    self.status = 'KO'
    self.save
  end

  private

end

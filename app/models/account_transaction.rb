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
  validates :bank_from_code, presence: true
  validates :bank_to_code, presence: true

  def update_as_ok
    update_attributes(status: 'OK')
  end

  def update_as_ko
    update_attributes(status: 'KO')
  end

  def external_pending_transaction?
    self.transaction_type == 'EXTERNAL' && self.status == 'PENDING'
  end

  def from_pending_to_ok
    bank_from = account&.customer&.bank
    bank_from_condition = bank_from.bank_conditions.where(external_bank_number: bank_to_code).first

    amount_to_withdraw = transefered_amount + bank_from_condition.commission
    update_as_ok if account.withdraw(amount_to_withdraw)
  end

  def from_pending_to_ko
    update_as_ko
  end

  private

end

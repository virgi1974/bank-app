class Account < ApplicationRecord
  belongs_to :customer
  has_many :account_transactions

  validates :account_number, presence: true, uniqueness: :true
  validates :balance, presence: true, numericality: true

  def withdraw(amount, allow_negative_balance = true)
    return false if allow_negative_balance == false
    lock!
    update_attributes(balance: balance - amount)
  end

  def deposit(amount)
    lock!
    update_attributes(balance: balance + amount)
  end

  def self.direct_internal_trasaction(account_from, account_to, amount)
    allow_negative_balance = (account_from.balance - amount > 0.0)
    return false if allow_negative_balance == false

    db_transaction = Account.transaction do
      withdrow_ok = account_from.withdraw(amount, allow_negative_balance)
      deposit_ok  = account_to.deposit(amount)
      withdrow_ok && deposit_ok
    end

    db_transaction
  end

end

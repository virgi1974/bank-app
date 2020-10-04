require 'rails_helper'

RSpec.describe Transfers::Internal, type: :model do
  before do
    @account = create(:account)
  end

  context 'fails' do
    it 'returns an array' do
      params_attr = {account_from: Faker::Bank.account_number, account_to: Faker::Bank.account_number, amount: 500}
      transfer = Transfers::Internal.new(params_attr).call
      expect(transfer).to be_an_instance_of(Array)
    end

    it 'when account_from not in DB' do
      non_existing_account = Faker::Bank.account_number
      expect(Account.find_by(account_number: non_existing_account)).to be(nil)

      params_attr = {account_from: non_existing_account, account_to: @account.account_number, amount: 500}
      transfer = Transfers::Internal.new(params_attr).call

      expect(transfer).to eq [Transfers::Internal::ERROR_MESSAGES[:account_from]]
    end

    it 'when account_to not in DB' do
      non_existing_account = Faker::Bank.account_number
      expect(Account.find_by(account_number: non_existing_account)).to be(nil)

      params_attr = {account_from: @account.account_number, account_to: non_existing_account, amount: 500}
      transfer = Transfers::Internal.new(params_attr).call

      expect(transfer).to eq [Transfers::Internal::ERROR_MESSAGES[:account_to]]
    end

    it 'when amount not valid' do
      account_to = create(:account, account_number: Faker::Bank.account_number,
                                    customer_id: @account.customer_id,
                                    balance: 3000.444)

      params_attr_1 = {account_from: @account.account_number, account_to: account_to.account_number, amount: 'a'}
      transfer = Transfers::Internal.new(params_attr_1).call
      expect(transfer).to eq [Transfers::Internal::ERROR_MESSAGES[:amount]]

      params_attr_2 = {account_from: @account.account_number, account_to: account_to.account_number, amount: nil}
      transfer = Transfers::Internal.new(params_attr_2).call
      expect(transfer).to eq [Transfers::Internal::ERROR_MESSAGES[:amount]]
    end

    it 'when amount leaves balance in negative' do
      account_to = create(:account, account_number: Faker::Bank.account_number,
                                    customer_id: @account.customer_id,
                                    balance: 3000.444)

      amount = @account.balance + 1.0
      params_attr = {account_from: @account.account_number, account_to: account_to.account_number, amount: amount}
      transfer = Transfers::Internal.new(params_attr).call
      expect(transfer).to eq [Transfers::Internal::ERROR_MESSAGES[:balance]]
    end

    it 'creates a KO transaction' do
      account_to = create(:account, account_number: Faker::Bank.account_number,
                                     customer_id: @account.customer_id,
                                     balance: 3000.444)

      amount = BigDecimal(@account.balance - 1.0)
      params_attr = {account_from: @account.account_number, account_to: account_to.account_number, amount: amount}

      allow( Account ).to receive( :direct_internal_trasaction ).and_return( false )

      expect(AccountTransaction.count).to be 0
      transfer = Transfers::Internal.new(params_attr).call
      expect(transfer).to eq [Transfers::Internal::ERROR_MESSAGES[:db_transaction]]

      expect(AccountTransaction.count).to be 1
      transaction = AccountTransaction.first

      expect(transaction.account_id).to be @account.id
      expect(transaction.bank_to_account).to eq account_to.account_number
      expect(transaction.transaction_type).to eq 'INTERNAL'
      expect(transaction.status).to eq 'KO'
      expect(transaction.transefered_amount).to eq amount
    end
  end

  context 'success' do
    before do
      @account_to = create(:account, account_number: Faker::Bank.account_number,
                                    customer_id: @account.customer_id,
                                    balance: 3000.444)

      @amount = BigDecimal(@account.balance - 1.0)
      @params_attr = {account_from: @account.account_number, account_to: @account_to.account_number, amount: @amount}
    end

    it 'returns an empty array for errors' do
      transfer = Transfers::Internal.new(@params_attr).call
      expect(transfer).to eq []
    end

    it 'updates the balance in both accounts' do
      initial_account_from_balance = @account.balance
      initial_account_to_balance = @account_to.balance
      transfer = Transfers::Internal.new(@params_attr).call
      @account.reload
      @account_to.reload

      expect(@account.balance).to eq(initial_account_from_balance - @amount)
      expect(@account_to.balance).to eq(initial_account_to_balance + @amount)
    end

    it 'creates a OK transaction' do
      expect(AccountTransaction.count).to be 0
      Transfers::Internal.new(@params_attr).call

      expect(AccountTransaction.count).to be 1
      transaction = AccountTransaction.first

      expect(transaction.account_id).to be @account.id
      expect(transaction.bank_to_account).to eq @account_to.account_number
      expect(transaction.transaction_type).to eq 'INTERNAL'
      expect(transaction.status).to eq 'OK'
      expect(transaction.transefered_amount).to eq @amount
    end
  end
end
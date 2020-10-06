require 'rails_helper'

RSpec.describe Transfers::External, type: :model do
  before do
    @account = create(:account)
    @bank_condition = create(:bank_condition, bank_id: @account&.customer&.bank&.id)
  end

  context 'fails' do
    it 'returns an array' do
      params_attr = {bank_from_account: Faker::Bank.account_number, bank_to_account: Faker::Bank.account_number, amount: 500, bank_to_code: @bank_condition.external_bank_number}
      transfer = Transfers::External.new(params_attr).call
      expect(transfer).to be_an_instance_of(Array)
    end

    it 'when account_from not in DB' do
      non_existing_account = Faker::Bank.account_number
      expect(Account.find_by(account_number: non_existing_account)).to be(nil)

      params_attr = {bank_from_account: non_existing_account, bank_to_account: @account.account_number, amount: 500, bank_to_code: @bank_condition.external_bank_number}
      transfer = Transfers::External.new(params_attr).call

      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:account_from]]
    end

    it 'when account_from not in DB' do
      non_existing_account = Faker::Bank.account_number
      expect(Account.find_by(account_number: non_existing_account)).to be(nil)
      params_attr = {bank_from_account: non_existing_account, bank_to_account: 'xxxxxxxxxxx', amount: 500, bank_to_code: @bank_condition.external_bank_number}
      transfer = Transfers::External.new(params_attr).call

      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:account_from]]
    end

    it 'when amount not valid' do
      account_to = create(:account, account_number: Faker::Bank.account_number,
                                    customer_id: @account.customer_id,
                                    balance: 3000.444)

      params_attr_1 = {bank_from_account: @account.account_number, bank_to_account: account_to.account_number, amount: 'a'}
      transfer = Transfers::External.new(params_attr_1).call
      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:amount]]

      params_attr_2 = {bank_from_account: @account.account_number, bank_to_account: account_to.account_number, amount: nil}
      transfer = Transfers::External.new(params_attr_2).call
      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:amount]]
    end

    it 'when bank condition not present' do
      non_existing_bank_number = '5000'
      expect(BankCondition.find_by(external_bank_number: non_existing_bank_number)).to be nil
      params_attr = {bank_from_account: @account.account_number, bank_to_account: 'xxxxxxxxxxxx', amount: 100, bank_to_code: non_existing_bank_number}
      transfer = Transfers::External.new(params_attr).call
      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:bank_condition_misssing]]
    end

    it 'when withdrawing exceeds max amount' do
      amount = @bank_condition.max_amount + 1.0
      params_attr = {bank_from_account: @account.account_number, bank_to_account: 'xxxxxxxxxxxx', amount: amount, bank_to_code: @bank_condition.external_bank_number}
      transfer = Transfers::External.new(params_attr).call
      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:amount_exceeds_limit]]
    end

    it 'when withdrawing exceeds max amount + commission' do
      @account.update_attributes(balance: @bank_condition.max_amount+1)
      amount = @bank_condition.max_amount - 1

      params_attr = {bank_from_account: @account.account_number, bank_to_account: 'xxxxxxxxxxxx', amount: amount, bank_to_code: @bank_condition.external_bank_number}
      transfer = Transfers::External.new(params_attr).call
      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:balance_incorrect]]
    end

    it 'creates a KO transaction' do
      amount = BigDecimal(10)
      params_attr = {bank_from_account: @account.account_number, bank_to_account: 'xxxxxxxxx', amount: amount, bank_to_code: @bank_condition.external_bank_number}

      expect(AccountTransaction.count).to be 0
      transfer = Transfers::External.new(params_attr).call
      expect(transfer).to eq [Transfers::External::ERROR_MESSAGES[:ta_transaction_ko]]

      expect(AccountTransaction.count).to be 1
      transaction = AccountTransaction.first

      expect(transaction.account_id).to be @account.id
      expect(transaction.bank_to_account).to eq 'xxxxxxxxx'
      expect(transaction.transaction_type).to eq 'EXTERNAL'
      expect(transaction.status).to eq 'KO'
      expect(transaction.transefered_amount).to eq amount
    end
  end

  context 'success' do
    before do
      @account_to = create(:account, account_number: Faker::Bank.account_number,
                                    customer_id: @account.customer_id,
                                    balance: 3000.444)

      @amount = 5.to_d
      @params_attr = {bank_from_account: @account.account_number, bank_to_account: @account_to.account_number, amount: @amount, bank_to_code: @bank_condition.external_bank_number}
      allow_any_instance_of(Client::Ta).to receive(:confirm_transaction).and_return("{\"message\":{\"result\":\"OK\"}}")
    end

    it 'returns an empty array for errors' do
      transfer = Transfers::External.new(@params_attr).call
      expect(transfer).to eq []
    end

    it 'creates a OK transaction' do
      allow_any_instance_of(Client::Ta).to receive(:confirm_transaction).and_return("{\"message\":{\"result\":\"OK\"}}")

      amount = 5.to_d
      params_attr = {bank_from_account: @account.account_number, bank_to_account: 'xxxxxxxxx', amount: amount, bank_to_code: @bank_condition.external_bank_number}

      expect(AccountTransaction.count).to be 0
      transfer = Transfers::External.new(params_attr).call

      expect(AccountTransaction.count).to be 1
      transaction = AccountTransaction.first

      expect(transaction.account_id).to be @account.id
      expect(transaction.bank_to_account).to eq 'xxxxxxxxx'
      expect(transaction.transaction_type).to eq 'EXTERNAL'
      expect(transaction.status).to eq 'OK'
      expect(transaction.transefered_amount).to eq amount
    end

    it 'updates the balance in the account_from' do
      initial_account_from_balance = @account.balance
      total_amount_to_substract = @amount + @bank_condition.commission

      transfer = Transfers::External.new(@params_attr).call
      @account.reload

      expect(@account.balance).to eq(initial_account_from_balance - total_amount_to_substract)
    end
  end
end
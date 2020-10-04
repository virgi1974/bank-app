require 'rails_helper'

RSpec.describe Account, type: :model do
  context 'associations' do
    it { should belong_to(:customer) }
  end

  context 'validations' do
    it { should validate_presence_of(:balance) }
    it { should validate_numericality_of(:balance) }
    it { should validate_presence_of(:account_number) }
  end

  # let(:partner_unavailable) { Partner.create! name: partner_name,
  #                                             offers_availability: false
  #   }

  context 'transactions' do
    before do
      @account = create(:account)
    end

    describe '#withdraw' do
      context 'success' do
        it 'when amount smaller than balance' do
          current_balance = @account.balance
          smaller_amount = current_balance - 1
          expect(@account.withdraw(smaller_amount)).to be(true)
          expect(@account.balance).to eq(current_balance - smaller_amount)
        end

        it 'when amount bigger than balance and not overpassing allow_negative_balance condition' do
          initial_balance = @account.balance
          bigger_amount = initial_balance + 1
          expect(@account.withdraw(bigger_amount)).to be(true)
          expect(@account.balance).to eq(initial_balance - bigger_amount)
        end
      end

      context 'fails' do
        it 'fails when substracting an amount bigger than balance' do
          initial_balance = @account.balance
          bigger_amount = initial_balance + 1
          expect(@account.withdraw(bigger_amount, false)).to be(false)
          expect(@account.balance).to eq(initial_balance)
        end
      end
    end

    describe '#deposit' do
      it 'success when adding any amount' do
        initial_balance = @account.balance
        amount = rand(1..5)
        expect(@account.deposit(amount)).to be(true)
        expect(@account.balance).to eq(initial_balance + amount)
      end
    end

    describe '#direct_internal_trasaction' do
      context 'success' do
        it 'substracting amount under the current balance' do
          account_to = create(:account, account_number: Faker::Bank.account_number,
                                        customer_id: @account.customer_id,
                                        balance: 3000.444)
          amount = 10.5
          initial_account_from_balance = @account.balance
          initial_account_to_balance = account_to.balance
          expect(initial_account_from_balance - amount).to be > 0.0

          result = Account.direct_internal_trasaction(@account, account_to, amount)
          expect(result).to be(true)
          expect(@account.balance).to eq(initial_account_from_balance - amount)
          expect(account_to.balance).to eq(initial_account_to_balance + amount)
        end
      end

      context 'failure' do
        it 'substracting amount over the current balance' do
          account_to = create(:account, account_number: Faker::Bank.account_number,
                                        customer_id: @account.customer_id,
                                        balance: 3000.444)
          amount = @account.balance + 1.1
          initial_account_from_balance = @account.balance
          initial_account_to_balance = account_to.balance
          expect(initial_account_from_balance - amount).to be < 0.0

          result = Account.direct_internal_trasaction(@account, account_to, amount)
          expect(result).to be(false)
          expect(@account.balance.to_d).to eq BigDecimal(initial_account_from_balance).to_d
          expect(account_to.balance.to_d).to eq BigDecimal(initial_account_to_balance).to_d
        end
      end
    end
  end
end

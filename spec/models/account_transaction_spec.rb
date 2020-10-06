require 'rails_helper'

RSpec.describe AccountTransaction, type: :model do
  it { should belong_to(:account) }

  it { should validate_presence_of(:transaction_type) }
  it { is_expected.to validate_inclusion_of(:transaction_type).in_array(AccountTransaction::TRANSACTION_TYPES) }
  it { should validate_presence_of(:status) }
  it { is_expected.to validate_inclusion_of(:status).in_array(AccountTransaction::STATUS_TYPES) }
  it { should validate_numericality_of(:transefered_amount) }
  it { should validate_presence_of(:transefered_amount) }
  it { should validate_presence_of(:bank_from_code) }
  it { should validate_presence_of(:bank_to_code) }

  context 'methods' do
    let(:pending_transaction) { create(:account_transaction, transaction_type: 'EXTERNAL') }
    let!(:bank_condition) { create(:bank_condition, bank_id: pending_transaction&.account&.customer&.bank&.id) }
  	
  	it 'initialized correctly' do
  		expect(pending_transaction.status).to eq 'PENDING'
      expect(pending_transaction.transaction_type).to eq 'EXTERNAL'
  	end

  	describe '#update_as_ok' do
  		it 'changes the status to OK' do
  			pending_transaction.update_as_ok
        expect(pending_transaction.status).to eq 'OK'
  		end
  	end

    describe '#update_as_ko' do
      it 'changes the status to KO' do
        pending_transaction.update_as_ko
        expect(pending_transaction.status).to eq 'KO'
      end
    end

    describe '#external_pending_transaction?' do
      it "returns true when 'PENDING' and 'EXTERNAL'" do
        expect(pending_transaction.transaction_type).to eq 'EXTERNAL'
        expect(pending_transaction.external_pending_transaction?).to be true
      end

      it "returns false when not 'PENDING' or 'EXTERNAL'" do
        allow( pending_transaction ).to receive( :transaction_type ).and_return( 'INTERNAL' )
        expect(pending_transaction.transaction_type).to eq 'INTERNAL'
        expect(pending_transaction.external_pending_transaction?).to be false
      end
    end

    describe '#from_pending_to_ok' do
      it 'changes the status to OK' do
        pending_transaction.from_pending_to_ok
        expect(pending_transaction.status).to eq 'OK'
      end

      it 'deposits money in related account' do
        related_account = pending_transaction&.account
        initial_balance = related_account.balance
        bank_from = related_account&.customer&.bank
        bank_from_condition = bank_from.bank_conditions.where(external_bank_number: pending_transaction.bank_to_code).first
        amount_to_withdraw = pending_transaction.transefered_amount + bank_from_condition.commission

        pending_transaction.from_pending_to_ok
        related_account.reload

        expect(related_account.balance).to eq(initial_balance - amount_to_withdraw)
      end
    end

    describe '#from_pending_to_ko' do
      it 'changes the status to KO' do
        pending_transaction.from_pending_to_ko
        expect(pending_transaction.status).to eq 'KO'
      end
    end
  end
end

module Transfers
  class Incoming

    ERROR_MESSAGES = { account_from: 'invalid origin account',
                       account_to: 'invalid target account',
                       amount: 'invalid amount type',
                       db_transaction: 'some db error during the transaction',
                       balance: 'amount to withdraw exceeds the balance' }

    def initialize(required_params)
      @account_to = Account.find_by(account_number:required_params[:bank_to_account])
      @bank_from_code = required_params[:bank_from_code]
      @bank_to_code = @account_to&.customer&.bank&.bank_number
      @amount = required_params[:transefered_amount]
      @errors = []
    end

    def call
      validations_ok = run_validations
      transaction_ok = (validations_ok ? create_transaction : false)

      @errors
    end

    private

    def run_validations
      validate_account_to
    end

    def validate_account_to
      return true if @account_to

      @errors << ERROR_MESSAGES[:account_to]
      false
    end

    def create_transaction
      accounts_updated = @account_to.deposit(@amount.to_d)
      account_transaction_created = create_account_transaction(accounts_updated)
      
      @errors << ERROR_MESSAGES[:db_transaction] unless accounts_updated && account_transaction_created
      accounts_updated && account_transaction_created
    end

    def create_account_transaction(accounts_updated)
      account_transaction = AccountTransaction.new(account_id: @account_to.id,
                                                   bank_to_account: @account_to.account_number,
                                                   bank_to_code: @bank_to_code,
                                                   bank_from_code: @bank_from_code,
                                                   transaction_type: 'INCOMING',
                                                   status: 'PENDING',
                                                   transefered_amount: @amount.to_d)
      

      if accounts_updated == true
        account_transaction.update_as_ok
      else
        account_transaction.update_as_ko
      end
    end
  end
end

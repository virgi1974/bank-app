module Transfers
  class Internal

    ERROR_MESSAGES = { account_from: 'invalid origin account',
                       account_to: 'invalid target account',
                       amount: 'invalid amount type',
                       db_transaction: 'some db error during the transaction',
                       balance: 'amount to withdraw exceeds the balance' }

    def initialize(required_params)
      @account_from = Account.find_by(account_number: required_params[:account_from])
      @account_to = Account.find_by(account_number: required_params[:account_to])
      @amount = required_params[:amount]
      @errors = []
    end

    def call
      validations_ok = run_validations
      transaction_ok = (validations_ok ? create_transaction : false)

      @errors
    end

    private

    def run_validations
      validate_account_from &&
      validate_account_to &&
      validate_amount_type &&
      validate_balance_for_transfer
    end

    def validate_account_from
      return true if @account_from

      @errors << ERROR_MESSAGES[:account_from]
      false
    end

    def validate_account_to
      return true if @account_to

      @errors << ERROR_MESSAGES[:account_to]
      false
    end

    def validate_amount_type
      return true if BigDecimal.new(@amount)

      @errors << ERROR_MESSAGES[:amount]
      false

    rescue ArgumentError, TypeError
      @errors << ERROR_MESSAGES[:amount]
      false
    end

    def validate_balance_for_transfer
      return true if @account_from.balance.to_f - @amount.to_f > 0.0

      @errors << ERROR_MESSAGES[:balance]
      false
    end

    def create_transaction
      accounts_updated = Account.direct_internal_trasaction(@account_from, @account_to, @amount.to_d)
      account_transaction_created = create_account_transaction(accounts_updated)

      @errors << ERROR_MESSAGES[:db_transaction] unless accounts_updated && account_transaction_created
      accounts_updated && account_transaction_created
    end

    def create_account_transaction(accounts_updated)
      account_transaction = AccountTransaction.new(account_id: @account_from.id,
                                                   related_account: @account_to.account_number,
                                                   transaction_type: 'INTERNAL',
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

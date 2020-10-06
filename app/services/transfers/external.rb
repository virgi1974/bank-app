module Transfers
  class External

    ERROR_MESSAGES = { account_from: 'invalid origin account',
                       amount: 'invalid amount type',
                       db_transaction: 'some db error during the transaction',
                       balance: 'amount to withdraw exceeds the balance',
                       amount_exceeds_limit: 'amount to withdraw exceeds the limit allowed',
                       balance_incorrect: 'the amount exceeds the current balance',
                       bank_condition_misssing: 'missing conditions for that bank',
                       ta_transaction_ok: 'TA transaction OK',
                       ta_transaction_ko: 'TA transaction KO' }

    def initialize(required_params)
      @bank_from_account = Account.find_by(account_number: required_params[:bank_from_account])
      @bank_to_account = required_params[:bank_to_account]

      @bank_from_code = @bank_from_account&.customer&.bank&.bank_number
      @bank_to_code = required_params[:bank_to_code]

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
      validate_amount_type &&
      validate_balance_for_transfer
    end

    def validate_account_from
      return true if @bank_from_account

      @errors << ERROR_MESSAGES[:account_from]
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
      bank_condition_to_apply = BankCondition.find_by(external_bank_number: @bank_to_code)

      if bank_condition_to_apply
        less_than_max_amount = BigDecimal.new(@amount) <= BigDecimal.new(bank_condition_to_apply.max_amount) ? true : false
        balance_correct = @bank_from_account.balance.to_d - @amount.to_d - bank_condition_to_apply.commission.to_d > 0.0

        return true if less_than_max_amount && balance_correct

        if !less_than_max_amount
          @errors << ERROR_MESSAGES[:amount_exceeds_limit]
        elsif !balance_correct
          @errors << ERROR_MESSAGES[:balance_incorrect]
        end
      end

      @errors << ERROR_MESSAGES[:bank_condition_misssing] unless bank_condition_to_apply
      false
    end

    def create_transaction
      account_transaction = AccountTransaction.create(account_id: @bank_from_account.id,
                                                      bank_to_account: @bank_to_account,
                                                      bank_to_code: @bank_to_code,
                                                      bank_from_code: @bank_from_code,
                                                      transaction_type: 'EXTERNAL',
                                                      status: 'PENDING',
                                                      transefered_amount: @amount.to_d)
      if account_transaction.id?
        ta_confirm_transaction(account_transaction)
      else
        @errors << ERROR_MESSAGES[:db_transaction]
      end
    end

    def ta_confirm_transaction(account_transaction)
      ta_client = Client::Bank.new(account_transaction)
      response = ta_client.confirm_transaction
      parsed_response = JSON.parse(response)

      if parsed_response['message']['result'] == 'OK'
        account_transaction.from_pending_to_ok
      else
        ok = account_transaction.from_pending_to_ko
        @errors << ERROR_MESSAGES[:ta_transaction_ko]
      end
    end
  end
end

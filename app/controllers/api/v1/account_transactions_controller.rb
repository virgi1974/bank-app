module Api
  module V1
    class AccountTransactionsController < ApplicationController
      def index
        search_term = params["type"]
        if search_term && AccountTransaction::TRANSACTION_TYPES.include?(search_term.upcase)
          @transactions = AccountTransaction.where(transaction_type: search_term.upcase)
        else
          @transactions = AccountTransaction.all
        end
      end
    end
  end
end

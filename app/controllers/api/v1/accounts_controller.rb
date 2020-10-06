module Api
  module V1
    class AccountsController < ApplicationController
      def internal_transaction
        errors = ::Transfers::Internal.new(internal_transfer_params).call
        compose_transfer_response(errors, 'internal')
      end

      def external_transaction
        errors = ::Transfers::External.new(external_transfer_params).call
        compose_transfer_response(errors, 'external')
      end

      private

      def internal_transfer_params
        params.permit(:account_from,
                      :account_to,
                      :amount)
      end

      def external_transfer_params
        params.permit(:bank_from_account,
                      :bank_to_account,
                      :bank_to_code,
                      :amount)
      end

      def compose_transfer_response(errors, type)
        @response = {}
        if errors.empty?
          @response[:message] = "#{type} transfer was successfull"
        else
          @response[:message] = "#{type} transfer failed"
          @response[:errors] = errors[0]
        end
        @response[:status] = 200
      end
    end
  end
end

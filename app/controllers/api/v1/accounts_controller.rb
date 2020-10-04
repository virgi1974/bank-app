module Api
  module V1
    class AccountsController < ApplicationController
      def internal_transaction
        errors = ::Transfers::Internal.new(internal_transfer_params).call
        compose_internal_transfer_response(errors)
      end

      def external_transaction
        
      end

      private

      def internal_transfer_params
        params.permit(:account_from, :account_to, :amount)
      end

      def compose_internal_transfer_response(errors)
        @response = {}
        if errors.empty?
          @response[:message] = 'internal transfer was successfull'
        else
          @response[:message] = 'internal transfer failed'
          @response[:errors] = errors[0]
        end
        @response[:status] = 200
      end
    end
  end
end

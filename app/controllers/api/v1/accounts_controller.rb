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

      def incoming_transaction
        errors = ::Transfers::Incoming.new(incoming_transfer_params).call
        compose_transfer_response(errors, 'incoming')
        render status: 200, json: @response.to_json
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

      def incoming_transfer_params
        params.permit(:bank_from_code,
                      :bank_to_code,
                      :bank_to_account,
                      :transefered_amount)
      end

      def compose_transfer_response(errors, type)
        @response = {}
        if errors.empty?
          @response[:message] = "#{type} transfer was successfull"
          @response[:result] = "OK"
        else
          @response[:message] = "#{type} transfer failed"
          @response[:errors] = errors[0]
          @response[:result] = "KO"
        end
        @response[:status] = 200
      end
    end
  end
end

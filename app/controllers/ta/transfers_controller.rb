module Ta
  class TransfersController < ApplicationController
    def transfer_between_banks
      random_error? ? compose_ko_message : transfer_from_bank_X_to_bank_Y
    end

    private

    def random_error?
      rand(1..10) <= 3
    end

    def compose_ok_message
      @message = { 'result': 'OK' }
    end

    def compose_ko_message
      @message = { 'result': 'KO' }
    end

    def transfer_from_bank_X_to_bank_Y
      bank_to = TaBankRegister.find_by(bank_number: strong_params[:bank_to_code])
      compose_ko_message and return unless bank_to

      client = Ta::Client.new(strong_params, bank_to.host)
      response = client.confirm_transaction
      parsed_response = JSON.parse(response)

      if parsed_response['result'] == 'OK'
        compose_ok_message
      else
        compose_ko_message
      end
    end

    def strong_params
      params.permit(:transaction_id, :bank_from_code ,:bank_to_code, :bank_to_account, :transefered_amount)
    end

  end
end

module Ta
  class TransfersController < ApplicationController
    def transfer_between_banks
      random_error? ? compose_ko_message : compose_ko_message
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
  end
end

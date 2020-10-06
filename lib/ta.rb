require 'net/http'
require 'net/https'

module Ta
  class Client
    include MessageHelper

    WEB_APP_TO_URL = '/api/v1/accounts/incoming_transaction'

    def initialize(transaction, url)
      @transaction = transaction
      @url = url
    end

    def transaction_data
      { bank_from_code: @transaction[:bank_from_code],
        bank_to_code: @transaction[:bank_to_code],
        bank_to_account: @transaction[:bank_to_account],
        transefered_amount: @transaction[:transefered_amount] }
    end

    def confirm_transaction
      url = URI("#{@url}#{WEB_APP_TO_URL}")

      request = ::Net::HTTP::Post.new(url)
      request["Accept"] = "application/json"
      request["Authorization"] = "Token someRandomTokenToUseInSomePoint"
      request["Content-Type"] = "application/json"

      request.body = transaction_data.to_json
      ssl_options = { use_ssl: url.scheme == "https", verify_mode: OpenSSL::SSL::VERIFY_NONE }

      begin
        Timeout::timeout(5) {
          @res = Net::HTTP.start(url.hostname, url.port, ssl_options) do |http|
            http.request(request)
          end
        }
      rescue Timeout::Error => e
        @res ||= compose_response_for_timeout_error
      rescue => e
        @res ||= compose_response_for_unexpected_error
      end

      @res.try(:body)
    end
  end
end
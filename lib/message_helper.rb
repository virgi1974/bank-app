module MessageHelper
  def compose_response_for_timeout_error
    response = Struct.new(:code, :msg) do
      def body
        message = { 'result': 'KO' }
        JSON.unparse(message)
      end
    end
    response.new('408', 'Timeout')
  end

  def compose_response_for_unexpected_error
    response = Struct.new(:code, :msg) do
      def body
        message = { 'result': 'KO' }
        JSON.unparse(message)
      end
    end
    response.new('500', 'Unexpected error')
  end
end

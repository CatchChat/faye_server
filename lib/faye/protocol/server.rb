module Faye
  class Server
    def make_response_with_ext(message)
      response = make_response_without_ext(message)
      response['ext'] = message['ext']
      response
    end

    alias_method_chain :make_response, :ext
  end
end

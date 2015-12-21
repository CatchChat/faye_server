module Faye
  class Server
    def make_response_with_ext(message)
      response = make_response_without_ext(message)
      response['ext'] = message['ext']
      response
    end

    def process_with_dispatch(messages, env, &callback)
      original_messages = [messages].flatten
      messages = []
      original_messages.each do |message|
        if /\A\/(users|circles)\/\S+\/messages\z/ =~ message['channel']
          FayeServer::VERSIONS.each do |version|
            _message = message.dup
            _message['channel'] = "/#{version}#{_message['channel']}"
            messages << _message
          end
        else
          messages << message
        end
      end

      process_without_dispatch(messages, env, &callback)
    end

    alias_method_chain :make_response, :ext
    alias_method_chain :process, :dispatch
  end
end

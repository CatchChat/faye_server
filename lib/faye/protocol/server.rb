module Faye
  class Server
    def make_response_with_ext(message)
      response = make_response_without_ext(message)
      response['ext'] = message['ext']
      response
    end

    def process_with_dispatch(messages, env, &callback)
      original_messages = [messages].flatten
      messages = parse_messages(original_messages)
      process_without_dispatch(messages, env, &callback)
    end

    alias_method_chain :make_response, :ext
    alias_method_chain :process, :dispatch

    private

    def parse_messages(messages)
      result = []
      messages.each do |message|
        if '/messages' == message['channel']
          recipient_type = message['data']['message']['recipient_type'].downcase.pluralize
          recipient_id = message['data']['message']['recipient_id']
          msgs = []
          case recipient_type
          when 'circles'
            user_ids = CirclesUser.where(circle_id: Circle.decrypt_id(recipient_id)).pluck(:user_id)
            user_ids.each do |user_id|
              msg = message.dup
              msg['channel'] = "users/#{User.encrypt_id(user_id)}/messages"
              msgs << msg
            end
          when 'users'
            message['channel'] = "users/#{recipient_id}/messages"
            msgs << message
          end

          msgs.each do |msg|
            FayeServer::VERSIONS.each do |version|
              _msg = msg.dup
              _msg['channel'] = "/#{version}/#{_msg['channel']}"
              result << _msg
            end
          end
        else
          result << message
        end
      end

      result
    rescue => ex
      Faye.logger.error "#{ex.inspect}\nBacktrace:\n#{ex.backtrace * "\n"}"
      []
    end
  end
end

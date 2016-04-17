require 'v1/publish_logic'
require 'v1/subscribe_logic'
module V1
  class ServerLogic

    class << self
      def incoming(faye_message)
        unless valid_channel?(faye_message['channel'])
          faye_message['error'] = Faye::Error.channel_invalid(faye_message['channel'])
          return
        end

        if logic_class = find_logic_class(faye_message['channel'])
          logic_class.incoming(faye_message)
        end
      end

      def outgoing(faye_message)
      end

      private

      def valid_channel?(channel)
        %w(/meta/connect /meta/disconnect /meta/handshake /meta/subscribe /meta/unsubscribe).include?(channel) ||
          /\A\/v1\/users\/\S+\/messages\z/ =~ channel
      end

      def find_logic_class(channel)
        case channel
        when '/meta/subscribe'
          V1::SubscribeLogic
        when /\A\/v1\/users\/\S+\/messages\z/
          V1::PublishLogic
        end
      end
    end
  end
end

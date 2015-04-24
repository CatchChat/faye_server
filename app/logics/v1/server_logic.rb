require 'v1/handshake_logic'
require 'v1/publish_logic'
require 'v1/subscribe_logic'
require 'v1/unsubscribe_logic'
require 'v1/connect_logic'
require 'v1/disconnect_logic'
module V1
  class ServerLogic

    class << self
      def incoming(faye_message)
        if logic_class = find_logic_class(faye_message['channel'])
          logic_class.incoming(faye_message)
        else
          faye_message['error'] = 'ChannelError: Channel is invalid.'
        end
      end

      def outgoing(faye_message)
      end

      private

      def find_logic_class(channel)
        case channel
        when '/meta/connect'
          V1::ConnectLogic
        when '/meta/disconnect'
          V1::DisconnectLogic
        when '/meta/handshake'
          V1::HandshakeLogic
        when '/meta/subscribe'
          V1::SubscribeLogic
        when '/meta/unsubscribe'
          V1::UnsubscribeLogic
        when /\A\/(users|circles)\/\S+\/messages\z/
          V1::PublishLogic
        end
      end
    end
  end
end

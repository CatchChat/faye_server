require 'v1/handshake_logic'
require 'v1/publish_logic'
require 'v1/subscribe_logic'
module V1
  class ServerLogic

    class << self
      def incoming(faye_message)
        logic_class(faye_message['channel']).incoming(faye_message)
      end

      def outgoing(faye_message)
        logic_class(faye_message['channel']).outgoing(faye_message)
      end

      private

      def logic_class(channel)
        if !channel.start_with? '/meta/'
          V1::PublishLogic
        elsif channel == '/meta/subscribe'
          V1::SubscribeLogic
        elsif channel == '/meta/handshake'
          V1::HandshakeLogic
        end
      end
    end
  end
end

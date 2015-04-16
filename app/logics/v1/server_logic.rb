require 'v1/handshake_logic'
require 'v1/publish_logic'
require 'v1/subscribe_logic'
module V1
  class ServerLogic

    class << self
      def incoming(faye_message)
        if !faye_message['channel'].include? '/meta/'
          V1::PublishLogic.incoming(faye_message)
        elsif faye_message['channel'] == '/meta/subscribe'
          V1::SubscribeLogic.incoming(faye_message)
        elsif faye_message['channel'] == '/meta/handshake'
          V1::HandshakeLogic.incoming(faye_message)
        end
      end

      def outgoing(faye_message)
        faye_message['ext'] = {}
      end
    end
  end
end

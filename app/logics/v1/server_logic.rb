require 'v1/handshake_logic'
require 'v1/publish_logic'
require 'v1/subscribe_logic'
module V1
  class ServerLogic

    def incoming(faye_message)
      if !faye_message['channel'].include? '/meta/'
        V1::PublishLogic.new.incoming(faye_message)
      elsif faye_message['channel'] == '/meta/subscribe'
        V1::SubscribeLogic.new.incoming(faye_message)
      elsif faye_message['channel'] == '/meta/handshake'
        V1::HandshakeLogic.new.incoming(faye_message)
      end
    end

    def outgoing(faye_message)
    end
  end
end

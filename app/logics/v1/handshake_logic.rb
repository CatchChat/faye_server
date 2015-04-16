require 'authentication'
module V1
  class HandshakeLogic
    extend Authentication

    class << self
      def incoming(faye_message)
        # TODO: need authenticate user
        # return unless authenticate_user(faye_message)
      end

      def outgoing(faye_message)
      end
    end
  end
end

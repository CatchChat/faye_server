require 'authentication'
module V1
  class HandshakeLogic
    include Authentication

    def incoming(faye_message)
      return unless user = authenticate_user(faye_message)
    end

    def outgoing(faye_message)
    end
  end
end

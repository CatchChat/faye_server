require 'authentication'
module V1
  class UnsubscribeLogic
    extend Authentication

    class << self
      def incoming(faye_message)
        authenticate_user(faye_message)
      end

      def outgoing(faye_message)
      end
    end
  end
end

module Faye
  module Engine
    class Proxy
      def publish_with_faye_server_logic(message)
        if (message['ext']['publish'] rescue true)
          publish_without_faye_server_logic(message.except('ext'))
        end
      end

      alias_method_chain :publish, :faye_server_logic
    end
  end
end

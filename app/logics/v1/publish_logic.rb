require 'authentication'
require 'rest-client'
module V1
  class PublishLogic
    extend Authentication

    MESSAGE_TYPES = %w(message instant_state mark_as_read message_deleted)

    class << self
      def incoming(faye_message)
        ActiveRecord::Base.clear_active_connections!
        data = faye_message['data']
        unless MESSAGE_TYPES.include?(data['message_type'])
          faye_message['error'] = "407:#{data['message_type']}:Message type is invalid"
          return
        end

        if data['message_type'] == 'instant_state'
          return unless user = authenticate_user(faye_message)

          unless data['message'].is_a?(Hash)
            faye_message['error'] = "407::Message is invalid"
            return
          end

          process_instant_state user, faye_message
        else
          if faye_message['ext'] && faye_message['ext']['publish_token']
            if faye_message['ext']['publish_token'] != ENV['PUBLISH_TOKEN']
              faye_message['error'] = "407:#{faye_message['ext']['publish_token']}:Publish token is invalid"
            end
          end
        end
      end

      def outgoing(faye_message)
      end

      private

      ## Process instant state message
      # * Clients Please check whether the user is in the channel *
      # In faye_message:
      #   ext
      #   data
      #     message_type    instant_state
      #     message
      #       state
      # Out faye_message:
      #   ext
      #   data
      #     message_type    instant_state
      #     message
      #       state
      #       user
      #         id
      #         nickname
      #         username
      def process_instant_state(user, faye_message)
        unless /\A\/v1\/(?<recipient_type>users|circles)\/(?<recipient_id>\S+)\/messages\z/ =~ faye_message['channel']
          faye_message['error'] = Faye::Error.channel_invalid(faye_message['channel'])
          return
        end

        faye_message['data'] = {
          'message_type' => 'instant_state',
          'message' => {
            'state' => faye_message['data']['message']['state'],
            'user' => {
              'id' => user.encrypted_id,
              'username' => user.username,
              'nickname' => user.nickname
            }
          }
        }
      end
    end
  end
end

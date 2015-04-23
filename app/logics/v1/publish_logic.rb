require 'authentication'
require 'rest-client'
module V1
  class PublishLogic
    extend Authentication

    MESSAGE_TYPES = %w(message instant_state mark_as_read)

    class << self
      def incoming(faye_message)
        if faye_message['ext'] && faye_message['ext']['publish_token']
          if faye_message['ext']['publish_token'] != ENV['PUBLISH_TOKEN']
            faye_message['error'] = "PublishError: Publish token is invalid."
          end
          return
        end

        return unless user = authenticate_user(faye_message)

        data = faye_message['data']
        unless MESSAGE_TYPES.include?(data['message_type'])
          return faye_message['error'] = "PublishError: Message type is invalid."
        end

        unless data['message'].is_a?(Hash)
          return faye_message['error'] = "PublishError: Message is invalid."
        end

        send "process_#{data['message_type']}", user, faye_message
      end

      def outgoing(faye_message)
      end

      private

      ## Process message
      # In faye_message:
      #   ext
      #   data
      #     message_type    mark_as_read
      #     message
      # Out faye_message:
      #   ext
      #   data
      #     message_type    mark_as_read
      #     message
      def process_message(user, faye_message)
        unless /\A\/(?<recipient_type>users|circles)\/(?<recipient_id>\S+)\/messages\z/ =~ faye_message['channel']
          return faye_message['error'] = 'PublishError: Channel is invalid.'
        end

        message = faye_message['data']['message']
        if (recipient_type == 'users' && message['recipient_type'] != 'User') ||
          (recipient_type == 'circles' && message['recipient_type'] != 'Circle') ||
          message['recipient_id'] != recipient_id
          return faye_message['error'] = 'PublishError: Message can not be sent to this channel.'
        end

        api_url = "#{ENV['API_SERVER_URL']}/v1/messages"
        headers = { Authorization: "Token token=\"#{faye_message['ext']['access_token']}\"", content_type: :json, accept: :json }

        RestClient.post(api_url, faye_message['data']['message'].merge('send_to_faye_server' => false).to_json, headers) do |response|
          json_response = Hash(JSON.load(response.body)) rescue {}
          if response.code >= 200 && response.code < 300
            faye_message['data'] = {
              'message_type' => 'message',
              'message' => json_response
            }
          elsif json_response['error']
            faye_message['error'] = json_response['error']
          else
            $logger.error "APIServerError: code is #{response.code}, body is #{response.body}"
            faye_message['error'] = "Internal error"
          end
        end
      end

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
        unless /\A\/(?<recipient_type>users|circles)\/(?<recipient_id>\S+)\/messages\z/ =~ faye_message['channel']
          return faye_message['error'] = 'PublishError: Channel is invalid.'
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

      ## Process mark as read message
      ## * Should be sent to the message sender mark_as_read message *
      # In faye_message:
      #   ext
      #   data
      #     message_type    mark_as_read
      #     message
      #       id
      # Out faye_message:
      #   ext
      #   data
      #     message_type    mark_as_read
      #     message
      #       id
      #       recipient_type
      #       recipient_id
      def process_mark_as_read(user, faye_message)
        unless /\A\/users\/\S+\/messages\z/ =~ faye_message['channel']
          return faye_message['error'] = 'PublishError: Channel is invalid.'
        end

        message_id = faye_message['data']['message']['id'].to_s
        return faye_message['error'] = 'PublishError: Message id is invalid.' if message_id == ''

        api_url = "#{ENV['API_SERVER_URL']}/v1/messages/#{message_id}/mark_as_read"
        headers = { Authorization: "Token token=\"#{faye_message['ext']['access_token']}\"", content_type: :json, accept: :json }

        RestClient.patch(api_url, { 'send_to_faye_server' => false }.to_json, headers) do |response|
          json_response = Hash(JSON.load(response.body)) rescue {}
          if response.code >= 200 && response.code < 300

            faye_message['data'] = {
              'message_type' => 'mark_as_read',
              'message' => {
                'id' => message_id,
                'recipient_type' => json_response['recipient_type'],
                'recipient_id' => json_response['recipient_id'],
                'first_read' => json_response['first_read']
              }
            }
          elsif json_response['error']
            faye_message['error'] = json_response['error']
          else
            $logger.error "APIServerError: code is #{response.code}, body is #{response.body}"
            faye_message['error'] = "Internal error"
          end
        end
      end
    end
  end
end

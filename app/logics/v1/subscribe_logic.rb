require 'authentication'
module V1
  class SubscribeLogic
    extend Authentication

    class << self
      # circle channel is like  /v1/circles/:id/messages
      # person channel is like  /v1/users/:id/messages
      def incoming(faye_message)
        return unless user = authenticate_user(faye_message)

        unless /\A\/v1\/(?<recipient_type>users|circles)\/(?<recipient_id>\S+)\/messages\z/ =~ faye_message['subscription']
          faye_message['error'] = Faye::Error.channel_invalid(faye_message['subscription'])
          return
        end

        return if recipient_type == 'circles' && CirclesUser.find_by(user_id: user.id, circle_id: CirclesUser.decrypt_id(recipient_id))
        return if recipient_type == 'users' && user.id == User.decrypt_id(recipient_id)

        faye_message['error'] = Faye::Error.channel_forbidden(faye_message['subscription'])
      end

      def outgoing(faye_message)
      end
    end
  end
end

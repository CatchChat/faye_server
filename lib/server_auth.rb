require_relative 'encrypted_id'
require_relative '../models/user'
require_relative '../models/access_token'
require_relative '../models/circles_user'

class ServerAuth

  def incoming(message, callback)
    puts message
    if !message['channel'].include? '/meta/'
      check_publish_permission(message)
    elsif message['channel'] == '/meta/subscribe'
      check_subscribe_permission(message)
    elsif message['channel'] == '/meta/handshake'
      # TODO: Interim measures
      #verify_access_token(message)
    end
    callback.call(message)
  end

  def outgoing(message, callback)
    if message['error'] && message['channel'] == '/meta/handshake'
      message['advice'] ||= {}
      message['advice']['reconnect'] = 'none'
    end
    callback.call(message)
  end

  private

  def verify_access_token(message)
    unless token = (message['ext']['access_token'] rescue nil)
      message['error'] = 'AuthenticateError: No access token.'
      return
    end

    access_token = AccessToken.find_by token: token, active: true
    if access_token && (access_token.expired_at.nil? or access_token.expired_at > Time.now )
      return access_token.user
    else
      message['error'] = 'AuthenticateError: Your access token is invalid.'
      return
    end
  end

  def check_publish_permission(message)
    if (message['ext']['access_token'] rescue nil) && (message['data']['message_type'] rescue nil) == 'status'
      return unless user = verify_access_token(message)
      data = message.delete 'data'
      message['data'] = { 'message_type' => 'status', 'status' => data['status'], username: user.username, nickname: user.nickname }
    elsif (message['ext']['publish_token'] rescue nil) != ENV['PUBLISH_TOKEN']
      message['error'] = 'PublishError: Your publish token is invalid.'
    end
  end

  def check_subscribe_permission(message)
    return unless user = verify_access_token(message)

    # circle channel is like  /circles/:id/messages
    # person channel is like  /users/:id/messages
    channel = message['subscription']
    path_list = channel.split('/')
    type      = path_list[1]
    type_id   = path_list[2]

    unless type && type_id
      return message['error'] = 'SubscribeError: Channel is not found.'
    end

    type_id = CirclesUser.decrypt_id(type_id)
    return if type == 'circles' && CirclesUser.find_by(user_id: user.id, circle_id: type_id)
    return if type == 'users' && user.id == type_id.to_i

    return message['error'] = 'SubscribeError: You do not have permission to subscribe this channel.'
  end
end

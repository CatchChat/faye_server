require_relative 'lib/encrypted_id'
require_relative 'user'
require_relative 'access_token'
require_relative 'circles_user'

class ServerAuth
  def initialize
    @users = {}
  end

  def incoming(message, callback)
    puts message
    if message['channel'] == '/meta/handshake'
      # TODO: Interim measures
      #check_mobile_access_token(message)
    end
    if message['channel'] == '/meta/subscribe'
      check_subscribe_permission(message)
    end
    unless message['channel'].include? '/meta/'
      check_publish_permission(message)
    end
    callback.call(message)
  end

  def outgoing(message, callback)
    if message['channel'] == '/meta/handshake'
      if message['error']
        message['advice'] ||= {}
        message['advice']['reconnect'] = 'none'
      end
    end
    callback.call(message)
  end

  private
  def check_mobile_access_token(message)
    unless token = (message['ext']['access_token'] rescue nil)
      message['error'] = 'AuthenticateError: No token.'
      return
    end

    access_token = AccessToken.find_by token: token, active: true
    if access_token && (access_token.expired_at.nil? or access_token.expired_at > Time.now )
      return access_token.user
      # count the user
    else
      message['error'] = 'AuthenticateError: Your access token is invalid.'
      return
    end
  end

  def check_publish_permission(message)
    if (message['ext']['publish_token'] rescue nil) != ENV['PUBLISH_TOKEN']
      return message['error'] = 'PublishError: Your publish token is invalid.'
    end
  end

  def check_subscribe_permission(message)
    return unless user = check_mobile_access_token(message)

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

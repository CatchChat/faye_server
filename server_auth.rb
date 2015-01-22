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
      check_mobile_access_token(message)
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
    token = (message['ext']['access_token'] rescue nil)
    mobile = (message['ext']['mobile'] rescue nil)
    phone_code = (message['ext']['phone_code'] rescue nil)
    unless token && mobile && phone_code
      message['error'] = 'Unable to authenticate'
      return nil
    end
    user = User.find_by phone_code: phone_code, mobile: mobile
    access_token = AccessToken.find_by user_id: user.try(:id), token: token, active: true
    if access_token && (access_token.expired_at.nil? or access_token.expired_at > Time.now )
      return user
      # count the user
    else
      message['error'] = 'Unable to authenticate'
      return nil
    end
  end

  def check_publish_permission(message)
    token = (message['ext']['publish_token'] rescue nil)
    publish_token = 'my_hardcode_token'
    unless (token == publish_token)
      return message['error'] = 'Unable to publish'
    end
  end

  def check_subscribe_permission(message)
    return unless user = check_mobile_access_token(message)
    channel = message['subscription']
    # channel is like  /circles/:id/messages
    circle_id = channel.try {|c| c.split('/')[-2] }
    unless CirclesUser.find_by(user_id: user.id, circle_id: circle_id)
      message['error'] = 'Unable to subscribe'
    end
  end
end

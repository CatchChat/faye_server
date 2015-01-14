require_relative 'user'
require_relative 'access_token'

class ServerAuth
  def initialize
    @users = {}
  end

  def incoming(message, callback)
    if message['channel'] == '/meta/handshake'
      check_username_access_token(message)
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
  def check_username_access_token(message)
    token = (message['ext']['access_token'] rescue nil)
    username = (message['ext']['username'] rescue nil)
    unless token && username
      return message['error'] = 'Unable to authenticate'
    end
    user = User.find_by username: username
    access_token = AccessToken.find_by user_id: user.try(:id), token: token, active: true
    if access_token && access_token.expired_at > Time.now
      # count the user
    else
      return message['error'] = 'Unable to authenticate'
    end
  end
end

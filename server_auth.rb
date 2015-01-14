class ServerAuth
  def initialize
    @users = {}
  end

  def incoming(message, callback)
    if message['channel'] == '/meta/handshake'
      if 'token' == (message['ext']['access_token'] rescue nil)

        #@users[message['clientId']] = user
      else
        message['error'] = 'Unable to authenticate'
      end
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
end

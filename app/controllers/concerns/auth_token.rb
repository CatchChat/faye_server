module AuthToken
  extend NodePassword
  def warden
    env['warden']
  end

  def authenticated?
    # TODO: regenerate encrypted_password using devise

    if warden.authenticate(:password, :token, :node_password, :node_token)
      return true
    end
  end

  def current_user
    warden.user || @user
  end

  def self.check_username_password
    return unless request.headers['X-CatchChatAuth']
    username, plain_password = Base64.decode64(request.headers['X-CatchChatAuth']).split(':')
    if (user = User.find_by(username: username)) && user.valid_password?(plain_password)
      @user = user
      return true
    end
  end

  def self.check_access_token
    return unless token_encoded = request.headers['X-CatchChatToken']
    token_string = Base64.decode64(token_encoded)
    if access_token = AccessToken.find_by(token: token_string)
      @user = access_token.user
      return true
    end
  end

  Warden::Strategies.add(:password) do
    def valid?
      request.headers['X-CatchChatAuth']
    end

    def authenticate!
      check_access_token
    end
  end

  Warden::Strategies.add(:node_token) do
    def valid?
      request.headers['X-CatchChatToken']
    end

    def authenticate!
      check_node_user_id_token
    end
  end

  Warden::Strategies.add(:node_password) do
    def valid?
      request.headers['X-CatchChatAuth']
    end

    def authenticate!
      check_node_username_password
    end
  end

  Warden::Strategies.add(:node_token) do
    def valid?
      request.headers['X-CatchChatToken']
    end

    def authenticate!
      check_node_user_id_token
    end
  end
end

module Authentication

  def authenticate_user(faye_message)
    user = nil
    if token = faye_message['ext'] && faye_message['ext']['access_token']
      access_token = AccessToken.find_by token: token, active: true
      user = access_token.user if access_token && access_token.can_use?
    end

    if user.nil?
      faye_message['error'] = Faye::Error.new(401, [token], 'Access token is invalid').to_s
    elsif user.blocked?
      faye_message['error'] = Faye::Error.new(401, [token], 'User is blocked').to_s
      user = nil
    end

    user
  end
end

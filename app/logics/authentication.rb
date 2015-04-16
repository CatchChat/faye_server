module Authentication

  def authenticate_user(faye_message)
    user = nil
    if token = faye_message['ext'] && faye_message['ext']['access_token']
      access_token = AccessToken.find_by token: token, active: true
      user = access_token.user if access_token && access_token.can_use?
    end

    if user.nil?
      faye_message['error'] = 'AuthenticateError: Access token is invalid.'
    elsif user.blocked?
      faye_message['error'] = 'AuthenticateError: User is blocked.'
      user = nil
    end

    user
  end
end

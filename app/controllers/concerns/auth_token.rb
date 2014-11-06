module AuthToken
  extend NodePassword
  def warden
    request.env['warden']
  end

  def authenticated?
    # TODO: regenerate encrypted_password using devise
    warden.errors.add :general, 'no_auth'
    if warden.authenticate(:token, :password, :mobile, :node_password)
      return true
    end
  end

  def current_user
    warden.user || @user
  end

  def self.check_username_password(username, password)
    if (user = User.find_by(username: username)) && user.valid_password?(password)
      user
    end
  end

  def self.check_access_token(request)
    token = request.headers['AuthorizationToken']
    if access_token = AccessToken.find_by(token: token)
      access_token.user
    end
  end

  def self.check_mobile_and_sms_verification_code(mobile, sms_str)
    if sms_verification_code = SmsVerificationCode.find_by(mobile: mobile, token: sms_str)
      sms_verification_code.user
    end
  end
end


module AuthToken

  module Exceptions
    class TokenExpired < RuntimeError; end
    class TokenNotFound < RuntimeError; end
    class TokenInactive < RuntimeError; end
  end
  include Exceptions
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
    raise TokenNotFound unless access_token = AccessToken.find_by(token: token)
    raise TokenInactive unless access_token.active
    # nil means never expire
    if access_token.expired_at
      raise TokenExpired if  access_token.expired_at < Time.now
    end
    AccessToken.current = access_token
    access_token.user
  end

  def self.check_mobile_and_sms_verification_code(mobile, sms_str)
    if (sms_code = SmsVerificationCode.find_by(mobile: mobile, token: sms_str)) && sms_code.active == true && (!sms_code.expired_at or sms_code.expired_at > Time.now)
      sms_code.user
    end
  end
end


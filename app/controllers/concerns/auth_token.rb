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
    warden.errors.add :general, 'no_auth'
    if warden.authenticate(:token, :password, :mobile, :node_password, :node_original_username)
      return true
    end
  end

  def current_user
    warden.user || @user
  end

  def self.check_password(login, password)
    if (user = User.find_by(username: login)) && user.valid_password?(password)
      user
    elsif (user = User.find_by(mobile: login)) && user.valid_password?(password)
      user
    elsif (user = User.find_by(email: login)) && user.valid_password?(password)
      user
    end
  end

  def self.check_access_token(request)
    token = find_token(request)
    raise TokenNotFound unless access_token = AccessToken.find_by(token: token)
    raise TokenInactive unless access_token.active
    # nil means never expire
    if access_token.expired_at
      raise TokenExpired if  access_token.expired_at < Time.zone.now
    end
    AccessToken.current = access_token
    access_token.user
  end

  def self.check_mobile_and_sms_verification_code(phone_code, mobile, sms_str)
    SmsVerificationCode.verify_token  phone_code: phone_code, mobile: mobile, token: sms_str
  end

  private
  def self.find_token(request)
    header = request.headers['Authorization']
    header.match(/Token token=\"(.*)\"/)[1]
  rescue
    raise TokenNotFound
  end

end


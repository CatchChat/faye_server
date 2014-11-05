require 'auth_token'
Warden::Strategies.add(:password) do
  def valid?
    params[:login] && params[:password]
  end

  def authenticate!
    if user = AuthToken.check_username_password(params[:login], params[:password])
      success!(user)
    end
  end
end

Warden::Strategies.add(:token) do
  def valid?
    request.headers['AuthorizationToken']
  end

  def authenticate!
    if user = AuthToken.check_access_token(request)
      success!(user)
    end
  end
end

Warden::Strategies.add(:node_password) do
  def valid?
    params[:login] && params[:password]
  end

  def authenticate!
    if user = AuthToken.check_node_username_password(params[:login], params[:password])
      success!(user)
    end
  end
end


Warden::Strategies.add(:mobile) do
  def valid?
    params[:login] && params[:password]
  end

  def authenticate!
    if user = AuthToken.check_mobile_and_sms_verification_code(params[:login], params[:password])
      success!(user)
    end
  end
end

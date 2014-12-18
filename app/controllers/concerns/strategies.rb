require 'auth_token'

Warden::Strategies.add(:admin_password) do
  def valid?
    params[:user] && params[:user][:password] || session["user_id"]
  end

  def authenticate!
    if user_id = session["user_id"]
      if (user = User.find(user_id)) && user.admin
        success!(user)
      else
        halt!
      end
    elsif params[:user] && user = AuthToken.check_password(params[:user][:username], params[:user][:password])
      if user.blocked? || (user.admin == false)
        errors.add :general, 'user_is_blocked'
        halt!
      else
        session["user_id"]=user.id
        success!(user)
      end
    else
      errors.add :general, 'username_password_error'
      halt!
    end
  end
end

Warden::Strategies.add(:password) do
  def valid?
    params[:login] && params[:password]
  end

  def authenticate!
    if user = AuthToken.check_password(params[:login], params[:password])
      if user.blocked?
        errors.add :general, 'user_is_blocked'
        halt!
      else
        success!(user)
      end
    else
      errors.add :general, 'username_password_error'
    end
  end
end

Warden::Strategies.add(:token) do
  def valid?
    request.headers['Authorization']
  end

  def authenticate!
    request.env["devise.skip_trackable"] = true
    if user = AuthToken.check_access_token(request)
      if user.blocked?
        errors.add :general, 'user_is_blocked'
        halt!
      else
        success!(user)
      end
    else
      errors.add :general, 'access_token_error'
      halt!
    end
  end
end

Warden::Strategies.add(:node_password) do
  def valid?
    params[:login] && params[:password]
  end

  def authenticate!
    if user = AuthToken.check_node_username_password(params[:login], params[:password])
      if user.blocked?
        errors.add :general, 'user_is_blocked'
        halt!
      else
        user.password = params[:password]
        user.save
        success!(user)
      end
    else
      errors.add :general, 'username_password_error'
    end
  end
end


Warden::Strategies.add(:mobile) do
  def valid?
    params[:mobile] && params[:verify_code] && params[:phone_code]
  end

  def authenticate!
    if user = AuthToken.check_mobile_and_sms_verification_code(params[:phone_code], params[:mobile], params[:verify_code])
      if user.blocked?
        errors.add :general, 'user_is_blocked'
        halt!
      else
        success!(user)
      end
    else
      halt!
      errors.add :general, 'mobile_token_error'
    end
  end
end

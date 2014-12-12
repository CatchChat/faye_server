class Users::PasswordsController < Devise::PasswordsController
  include RateLimit
  # before_filter :configure_sign_in_params, only: [:create]
  before_action :authenticate_user, except: [:change_password, :send_verify_code]

  # Put password/update
  def change_password
    if authenticated? && params[:current_password]
      status = change_password_with_current_password
    else
      status = change_password_with_token
    end
    render json: {status: status.to_s}, status: status
  end


  # Post password/create
  def send_verify_code

    unless params[:mobile]  && params[:phone_code]
      return render json:{error: 'not enough data'}, status: :not_acceptable
    end
    mobile = params[:mobile]
    phone_code = params[:phone_code]
    random_num = rand(100000).to_s
    user = User.find_by mobile: mobile
    return render json: {status: "Not Found"}, status: :not_found unless user
    sms_code = SmsVerificationCode.create token:       random_num.to_s,
                                          active:      true,
                                          expired_at:  get_expired_at,
                                          user_id:     user.id,
                                          mobile:      mobile,
                                          phone_code:  phone_code
    content = t('auth.sms_verification_code_message', code: sms_code.token)

    sms_return_body = sms_code.send_msg(content)
    render json: {status: sms_return_body}, status: sms_return_body ? :created : :bad_request

  end

  private
  def change_password_with_current_password
    return :unauthorized unless current_user.valid_password?(params[:current_password])
    return :conflict unless params[:new_password] == params[:new_password_confirm]
    current_user.password = params[:new_password]
    return :not_acceptable unless current_user.valid?
    if current_user.save(validate: false)
      remove_old_access_token(current_user)
      :accepted
    else
      :not_acceptable
    end
  end

  def change_password_with_token
    return :not_acceptable unless phone_code = params[:phone_code]
    return :not_acceptable unless token = params[:token]
    return :not_acceptable unless mobile = params[:mobile]
    sms_token = SmsVerificationCode.find_by mobile: mobile, token: token, phone_code: phone_code
    return :not_found unless sms_token
    user = User.find_by mobile: sms_token.mobile
    return :not_found unless user
    return :gone unless sms_token.active && sms_token.expired_at > Time.now
    return :conflict unless params[:new_password] == params[:new_password_confirm]

    user.password = params[:new_password]
    return :not_acceptable unless user.valid?

    if user.save(validate: false)
      remove_old_access_token(user)
      :accepted
    else
      :not_acceptable
    end

  end

  def get_expired_at
    valid_period = 3600
    Time.now + valid_period
  end

  def remove_old_access_token(user)
    AccessToken.delete_all user_id: user.id
  end
end

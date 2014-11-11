class Users::PasswordsController < Devise::PasswordsController
  include RateLimit
  # before_filter :configure_sign_in_params, only: [:create]
  before_action :authenticate_user, except: [:change_password, :send_verify_code]

  # Put password/update
  def change_password
    if authenticated?
      status = change_password_with_current_password
    else
      status = change_password_with_token
    end
    render json: {status: status.to_s}, status: status
  end


  # Post password/create
  def send_verify_code
    mobile = params[:mobile]
    random_num = rand(100000).to_s
    user = User.find_by mobile: mobile
    return render json: {status: "Not Found"}, status: :not_found unless user
    sms_code = SmsVerificationCode.create token:       random_num.to_s,
                                          active:      true,
                                          expired_at:  get_expired_at,
                                          user_id:     user.id,
                                          mobile:      mobile
    content = t('auth.sms_verification_code_message', code: sms_code.token)

    success = sms_code.send_msg(content)
    render json: {status: success ? 'ok' : 'error'}, status: success ? :created : :bad_request

  end

  private
  def change_password_with_current_password
    return :unauthorized unless current_user.valid_password?(params[:current_password])
    return :conflict unless params[:new_password] == params[:new_password_confirm]
    current_user.password = params[:new_password]
    return :not_acceptable unless current_user.valid?
    if current_user.save(validate: false)
      :accepted
    else
      :not_acceptable
    end
  end

  def change_password_with_token
    :not_implemented
  end

  def get_expired_at
    valid_period = 3600
    Time.now + valid_period
  end
end

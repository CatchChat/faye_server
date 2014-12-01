class Users::RegistrationsController < Devise::RegistrationsController
  #include RateLimit
  skip_before_action :authenticate_user

  # Post registration/create
  def create
    @user = User.create! register_params
    @user.block
    @user.save
    @sent_sms = send_verify_code(@user)


  rescue ActiveRecord::RecordInvalid => e
    render json: {status: 'invalid user data', message: e.message}, status: :not_acceptable
  end

  # Put registration/update
  def update_token
    unless (username = params[:username]) && (mobile = params[:mobile]) && (token = params[:token])
      return render json:{status: 'not enough data'}, status: :not_acceptable
    end
    @user = User.find_by! username: username, mobile: mobile

    sms_token = SmsVerificationCode.find_by! user_id: @user.id, mobile: mobile, token: token, active: true

    if Time.now > sms_token.expired_at
      return render json: {status: 'token time out'}, status: :request_timeout
    end

    @user.unblock
    @user.save
    sms_token.active = false
    sms_token.save

  rescue ActiveRecord::RecordNotFound => e
    render json: {status: 'record not found', message: e.message}, status: :not_found
  end

  private

  def send_verify_code(user)
    mobile = params[:mobile]
    random_num = rand(100000).to_s
    sms_code = SmsVerificationCode.create token:       random_num.to_s,
                                          active:      true,
                                          expired_at:  get_expired_at,
                                          user_id:     user.id,
                                          mobile:      mobile
    content = t('auth.sms_verification_code_message', code: sms_code.token)

    sms_code.send_msg(content)
  end

  def get_expired_at
    valid_period = 3600
    Time.now + valid_period
  end

  def register_params
    params.permit :username, :password, :mobile, :phone_code
  end
end

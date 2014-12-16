class Users::RegistrationsController < Devise::RegistrationsController
  #include RateLimit
  skip_before_action :authenticate_user

  # Post registration/create
  def create
    unless params[:username] && params[:mobile] && params[:password] && params[:phone_code]
      return render json:{status: 'not enough data'}, status: :not_acceptable
    end
    @user = User.create! register_params
    @user.block
    @user.save!
    @sent_sms = send_verify_code(@user).to_s


  rescue ActiveRecord::RecordInvalid => e
    render json: {status: 'invalid user data', error: e.message}, status: :not_acceptable
  end

  # Put registration/update
  def update_token
    unless (username = params[:username]) && (mobile = params[:mobile]) && (token = params[:token]) && (phone_code = params[:phone_code])
      return render json:{status: 'not enough data'}, status: :not_acceptable
    end
    @user = User.find_by! username: username, mobile: mobile, phone_code: phone_code

    unless SmsVerificationCode.verify_token phone_code: phone_code, mobile: mobile, token: token
      return render json: {status: 'token time out'}, status: :request_timeout
    end
    @user.unblock
    @user.save
    # handle by client
    # add_official_as_friend_receive_welcome_message

  rescue ActiveRecord::RecordNotFound => e
    render json: {status: 'record not found', error: e.message}, status: :not_found
  end

  private

  def send_verify_code(user)
    mobile = user.mobile
    phone_code = user.phone_code
    random_num = rand(100000).to_s
    sms_code = SmsVerificationCode.create token:       random_num.to_s,
                                          active:      true,
                                          expired_at:  get_expired_at,
                                          user_id:     user.id,
                                          mobile:      mobile,
                                          phone_code:  phone_code
    content = t('auth.sms_verification_code_message', code: sms_code.token)

    sms_code.send_msg(content)
  rescue => e
    render json: {status: 'sms provider error', error: e.message}, status: :service_unavailable
  end

  def get_expired_at
    valid_period = 3600
    Time.now + valid_period
  end

  def register_params
    params.permit :username, :password, :mobile, :phone_code
  end

  def add_official_as_friend_receive_welcome_message
     Friendship.create_friendships(@user, official_user)
     Message.create_by_official_message!(official_user, @user)
  end

  def official_user
    User.find_by username: Settings.official_accounts.first
  end
end

class Users::RegistrationsController < Devise::RegistrationsController
  include RateLimit
  before_action :authenticate_user, except: [:create, :update]

  # Post registration/create
  def create
    @user = User.create! username:  params[:username],
                         password:  params[:password],
                         mobile:    params[:mobile]
    @user.block
    @user.save
    @sent_sms = send_verify_code(@user)


  rescue ActiveRecord::RecordInvalid => e
    render json: {status: 'invalid user data', message: e.message}, status: :not_acceptable
  end

  # Put registration/update
  def update
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
end

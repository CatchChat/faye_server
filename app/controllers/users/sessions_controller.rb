class Users::SessionsController < Devise::SessionsController
  include RateLimit
  # before_filter :configure_sign_in_params, only: [:create]
  before_action :authenticate_user, except: [:send_verify_code, :check_verify_code]

  # Post auth/token_by_login
  def create
    get_access_token
  end

  # Post auth/token_by_mobile
  def create_by_mobile
    get_access_token
  end

  # Post auth/send_verify_code
  def send_verify_code
    unless (mobile = params[:mobile]) && (phone_code = params[:phone_code])
      return render json:{status: 'not enough data'}, status: :not_acceptable
    end
    random_num = rand(100000).to_s
    user = current_user or User.find_by!(mobile: mobile, phone_code: phone_code)
    sms_code = SmsVerificationCode.create token:       random_num.to_s,
                                          active:      true,
                                          expired_at:  get_expired_at,
                                          user_id:     user.id,
                                          mobile:      mobile,
                                          phone_code:  phone_code

    content = t('auth.sms_verification_code_message', code: sms_code.token)

    @success = sms_code.send_msg(content)
    @mobile = mobile

  rescue ActiveRecord::RecordNotFound => e
    render json: {status: 'record not found', error: e.message}, status: :not_found
  end

  def check_verify_code
    unless (mobile = params[:mobile]) && (phone_code = params[:phone_code]) && (token = params[:token])
      return render json:{status: 'not enough data'}, status: :not_acceptable
    end
    unless SmsVerificationCode.verify_token mobile: mobile, token: token, phone_code: phone_code
      return render json: {status: 'token is not active or expired'}, status: :gone unless sms_token.active && sms_token.expired_at > Time.zone.now
    end
    render json: {status: 'mobile verified'}, status: :ok
  end

  private
  def get_access_token
    @user = current_user

    token = AccessToken.create user_id:     @user.id,
                               active:      true,
                               token:       @user.generate_token,
                               creator_ip:  request.ip,
                               client:      get_client,
                               expired_at:  get_expired_at
    @access_token = token
  end

  def get_client
    official_flag = AccessToken.clients['official']
    params.fetch(:client, official_flag).to_i
  end

  def get_expired_at
    valid_period = params.fetch(:expiring, 7*24*3600).to_i
    valid_period == 0 ? nil : Time.zone.now + valid_period
  end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end

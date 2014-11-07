class Users::SessionsController < Devise::SessionsController
  include RateLimit
  # before_filter :configure_sign_in_params, only: [:create]
  before_action :authenticate_user, except: [:send_verify_code]

  # Post auth/token_by_login
  def create
    get_access_token
  end

  # Post auth/token_by_mobile
  def create_by_mobile
    @mobile = true
    get_access_token
  end

  def get_access_token
    @user = current_user
    token = AccessToken.create user_id: @user.id,
      active: true,
      token: @user.generate_token
    @access_token = token
  end

  # Post auth/send_verify_code
  def send_verify_code
    mobile = params[:login].to_s
    random_num = rand(100000).to_s
    user = User.find_by(mobile: mobile)
    sms_code = SmsVerificationCode.create token: random_num.to_s,
                                          user_id: user.id,
                                          mobile: mobile
    content = t('auth.sms_verification_code_message', code: sms_code.token)
    @success = send_sms(mobile, content)
  end
  private

  def send_sms(mobile, content)
    code, body = sms.send_sms mobile: mobile, message: content
    return true if code == 200 && body == "{\"error\":0,\"msg\":\"ok\"}"
  end

  def sms
    username         = ENV["luosimao_username"]
    apikey           = ENV["luosimao_apikey"]
    init_hash       = {username: username, apikey: apikey}
    luosimao_client = LuosimaoSms.new init_hash
    Sms.new(luosimao_client, init_hash)
  end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end

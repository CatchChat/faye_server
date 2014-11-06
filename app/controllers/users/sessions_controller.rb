require 'strategies'
class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  include AuthToken
  before_action :authenticate_user, except: [:new]
  def create
    @user = current_user
    @access_token = current_user.access_token
    @mobile = true if request.path.match 'by_mobile'
  end

  def new
    mobile = params[:login].to_s
    random_num = rand(100000).to_s
    user = User.find_by(mobile: mobile)
    user.sms_verification_code ||= SmsVerificationCode.create token: random_num.to_s,
                                                              mobile: mobile
    user.sms_verification_code.save
    content = t('.sms_verification_code_message', code: user.sms_verification_code.token)
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

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end

require 'strategies'
class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  include AuthToken
  before_action :authenticate_user
  def create
    @user = current_user
    @access_token = current_user.access_token
    @mobile = true if request.path.match 'by_mobile'
  end

  private

  def authenticate_user
    render json: { error: "Unauthorized!" }, status: :unauthorized unless authenticated?
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

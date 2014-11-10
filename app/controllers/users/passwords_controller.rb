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
  end

  private
  def change_password_with_current_password
    return :unauthorized unless current_user.valid_password?(params[:current_password])
    return :conflict unless params[:new_password] == params[:new_password_confirm]

    user = User.find current_user.id
    user.password = params[:new_password]
    current_user.password = params[:new_password]
    if user.save
      :accept
    else
      :not_acceptable
    end
  end

  def change_password_with_token
    :not_implemented
  end
end

require 'strategies'
class Admins::SessionsController < ApiController
  skip_before_action :authenticate_user, only: [:new, :create]
  def new
    @user = User.new
  end

  def create
    resource = warden.authenticate!(:admin_password)
    redirect_to new_admins_session unless resource
    sign_in(resource)
    redirect_to admins_users_url
  end

  def logout
    session['user_id']=nil
    redirect_to new_admins_session_path
  end

end

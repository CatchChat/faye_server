class Admins::UsersController < ApiController
  def index
    @users = User.order(:username).page params[:page]
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy
    redirect_to admins_users_url
  end
end

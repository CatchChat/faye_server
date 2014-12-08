class Admins::UsersController < ApiController
  def index
    @users = User.order(:username).page params[:page]
  end

end

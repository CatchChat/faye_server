class Users::RegistrationsController < Devise::RegistrationsController
  include RateLimit
  before_action :authenticate_user, except: [:create, :update]

  def create
    @user = User.create! username:  params[:username],
                 password:  params[:password],
                 mobile:    params[:mobile]
    @user.block
    @user.save

  rescue ActiveRecord::RecordInvalid => e
    render json: {status: 'invalid user data', message: e.message}, status: :not_acceptable
  end
end

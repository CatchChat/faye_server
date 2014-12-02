class Admins::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user

  def new
    @user = User.new
  end

  def create
    self.resource = warden.authenticate!(:admin_password, scope: :admin)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: '/admin'
  end
end

class AuthController < ApiController
  def create
    render :text => 'token_by_login'
  end

  def index
    render :text => 'index'
  end

end

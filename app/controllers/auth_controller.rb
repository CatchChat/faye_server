class AuthController < ApiController

  def token_by_login
    render :text => 'token_by_login'
  end

  def index
    render :text => 'index'
  end

end

require 'auth_token'
class HomeController < ApplicationController
  include AuthToken

  before_action :authenticate_user

  def authenticate_user
    render :text => "Unauthorized!", :status => 401 unless authenticated?
  end

  def index
  end
end

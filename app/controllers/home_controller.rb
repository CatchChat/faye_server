require 'auth_token'
class HomeController < ApplicationController
  include AuthToken

  before_action :authenticate_user

  def authenticate_user
    render :text => {error: "Unauthorized!"}.to_json, :status => 401 unless authenticated?
  end

  def index
  end
end

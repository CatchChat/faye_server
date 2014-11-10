require 'strategies'
class ApplicationController < ActionController::Base
  include AuthToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  force_ssl if: :ssl_configured?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :password, :password_confirmation, :current_password) }
  end

  def authenticate_user
    render json: { error: t("auth.#{warden.errors[:general].last}") }, status: :unauthorized unless authenticated?
  end

  def ssl_configured?
    !!Settings.ssl_configured
  end

  def sort_column(klass, sort: params[:sort])
    klass.column_names.include?(sort) ? sort : 'id'
  end

  def sort_direction(direction = params[:direction])
    direction = direction.to_s.upcase
    %w(ASC DESC).include?(direction) ? direction : "DESC"
  end
end

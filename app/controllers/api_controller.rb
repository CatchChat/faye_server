require 'strategies'
class ApiController < ApplicationController
  include AuthToken

  before_action :set_locale
  before_action :authenticate_user

  def authenticate_user
    render json: { error: "Unauthorized!" }, status: 401 unless authenticated?
  end

  def set_locale
    if request.headers['Accept-Language'].present? &&
      I18n.available_locales.include?(request.headers['Accept-Language'].to_sym)
      I18n.locale = locale
    end
    logger.debug "===> Set locale to #{I18n.locale}."
  end
end

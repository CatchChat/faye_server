require 'strategies'
class ApiController < ApplicationController
  include AuthToken

  before_action :set_locale
  before_action :authenticate_user
  before_action :set_time_zone

  helper_method :format_time, :format_time_to_iso8601

  private

  def authenticate_user
    render json: { error: "Unauthorized!" }, status: 401 unless authenticated?
  end

  def set_locale
    if request.headers['Accept-Language'].present? &&
      I18n.available_locales.include?(request.headers['Accept-Language'].to_sym)
      I18n.locale = request.headers['Accept-Language'].to_sym
    end
    logger.debug "===> Set locale to #{I18n.locale}."
  end

  def set_time_zone
    Time.zone = current_user.time_zone
  rescue
    Time.zone = 'Beijing'
  ensure
    logger.debug "===> Set time zone to #{Time.zone}."
  end

  def format_time(time, format = t('time.formats.default'))
    time.strftime(format) if time.present?
  end

  def format_time_to_iso8601(time)
    format_time(time, t('time.formats.iso8601'))
  end
end

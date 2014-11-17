class ApiController < ApplicationController
  include RateLimit

  before_action :set_locale
  before_action :authenticate_user
  before_action :set_time_zone
  skip_before_action :verify_authenticity_token

  helper_method :format_time, :format_time_to_iso8601

  private

  def set_locale
    I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
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

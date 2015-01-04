class ApiController < ApplicationController
  include RateLimit

  before_action :set_locale
  before_action :authenticate_user
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user, only: [:error_404]


  helper_method :format_time, :format_time_to_iso8601

  def error_404
    render json: {}, status: 404
  end
  private

  def set_locale
    I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
    logger.debug "===> Set locale to #{I18n.locale}."
  end

  def format_time(time, format = t('time.formats.default'))
    time.strftime(format) if time.present?
  end

  def format_time_to_iso8601(time)
    I18n.l(time, format: :iso8601)
  end

end

module RateLimit
  extend ActiveSupport::Concern

  included do
    prepend_before_action :set_rate_limit
    self.class.cattr_accessor :throttle_name
  end

  private

  def set_rate_limit
    rate_limit = request.env['rack.attack.throttle_data'].try(:[], self.class.throttle_name) || Hash.new(0)
    response.headers['X-RateLimit-Limit']     = rate_limit[:limit].to_s
    response.headers['X-RateLimit-Remaining'] = (rate_limit[:limit].to_i - rate_limit[:count].to_i).to_s
    response.headers['X-RateLimit-Reset']     = rate_limit[:period].to_s
  end
end

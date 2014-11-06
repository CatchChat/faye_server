Rack::Attack.cache.store = Redis.current

# user_login_regexp = /\A\/api\/v(\d+)\/auth\/(token_by_login|token_by_mobile)\/?\Z/
# 
# Rack::Attack.throttle('user_login', limit: Settings.rate_limit.user_login, period: 1.hour) do |req|
#   if req.path =~ user_login_regexp && req.ip && req.params[:login].present?
#     "#{req.ip}-#{req.params[:login].strip}"
#   end
# end

Rack::Attack.throttle('api_request', limit: Settings.rate_limit.api_request, period: 1.hour) do |req|
  if req.path.start_with?('/api/v')
    # FIXME use AuthorizationToken
    req.ip
  end
end

Rack::Attack.throttled_response = lambda { |env|
  rate_limit = env['rack.attack.match_data']
  remaining = rate_limit[:limit].to_i - rate_limit[:count].to_i
  remaining = 0 if remaining < 0
  [
    429,
    {
      'Content-Type'          => 'application/json',
      'X-RateLimit-Limit'     => rate_limit[:limit].to_s,
      'X-RateLimit-Remaining' => remaining.to_s,
      'X-RateLimit-Reset'     => rate_limit[:period].to_s
    },
    [{ error: I18n.t('messages.retry_after') }.to_json]
  ]
}

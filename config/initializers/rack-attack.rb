Rack::Attack.cache.store = Rails.cache

Rack::Attack.throttle(
  'api_request_without_login',
  limit: Settings.rate_limit.api_request_without_login.limit,
  period: Settings.rate_limit.api_request_without_login.period
) do |req|
  if req.path.start_with?('/api/v') && req.env['HTTP_AUTHORIZATION'].blank?
    req.ip
  end
end

Rack::Attack.throttle(
  'api_request_with_login',
  limit: Settings.rate_limit.api_request_with_login.limit,
  period: Settings.rate_limit.api_request_with_login.period
) do |req|
  if req.path.start_with?('/api/v') && req.env['HTTP_AUTHORIZATION'].present?
    Digest::MD5.hexdigest(req.env['HTTP_AUTHORIZATION'])
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
    [{ error: I18n.t('rate_limit_exceeded') }.to_json]
  ]
}

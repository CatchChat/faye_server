require 'request_variables'
require 'sidekiq'
require 'sidekiq/web'

Sidekiq.default_worker_options = { backtrace: true }

Sidekiq.configure_server do |config|
  config.redis = Settings.redis.sidekiq.to_hash
end

Sidekiq.configure_client do |config|
  config.redis = Settings.redis.sidekiq.to_hash
end

Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  (user = AuthToken.check_password(username, password)) && user.admin
end

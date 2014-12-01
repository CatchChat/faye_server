Sidekiq.default_worker_options = { backtrace: true }

Sidekiq.configure_server do |config|
  config.redis = Settings.redis.sidekiq.to_hash
end

Sidekiq.configure_client do |config|
  config.redis = Settings.redis.sidekiq.to_hash
end

module Sidekiq::Middleware::RequestVariables
  # Get the request variablers and store it in the message
  # to be sent to Sidekiq.
  class Client
    def call(worker_class, msg, queue, redis_pool)
      msg['access_token_id'] ||= AccessToken.current.try(:id)
      yield
    end
  end

  # Pull the msg locale out and set the current thread to use it.
  class Server
    def call(worker, msg, queue)
      if msg['access_token_id']
        AccessToken.current = AccessToken.find_by(id: msg['access_token_id'])
      end
      yield
    ensure
      AccessToken.current = nil
    end
  end
end

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::RequestVariables::Client
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::RequestVariables::Client
  end
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::RequestVariables::Server
  end
end

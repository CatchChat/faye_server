# This file is used by Rack-based servers to start the application.
require_relative 'config/application'
bayeux = Faye::RackAdapter.new(
  mount: '/faye',
  timeout: 10,
  engine: {
    type: Faye::Redis,
    host: ENV['REDIS_HOST'],
    port: ENV['REDIS_PORT'],
    database: ENV['REDIS_DB'],
    namespace: ENV['REDIS_NAMESPACE'],
  }
)
bayeux.add_websocket_extension(PermessageDeflate)
Faye::WebSocket.load_adapter('thin')

bayeux.add_extension(FayeServer.new)

run bayeux

rack_env = ENV['RACK_ENV'] || 'development'
Bundler.require(:default, rack_env)

[File.expand_path("app/models"), File.expand_path("app/logics"), File.expand_path("lib")].each do |path|
  $LOAD_PATH.unshift path
end

require 'active_record'
require 'active_support'
require 'faye'
require 'faye/protocol/server' # Rewrite Faye::Server#make_response
require 'faye/engines/proxy'   # Rewrite Faye::Engine::Proxy#publish
require 'faye/redis'
require 'faye/websocket'
require 'mysql2'
require 'permessage_deflate'
require 'dotenv'
Dotenv.load ".env.#{ENV['RACK_ENV']}", '.env'

require 'logger'
Faye.logger = Logger.new("log/#{rack_env}.log")
Faye.logger.level = Faye::Logging::LOG_LEVELS[ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].to_sym : :info]

require 'newrelic_rpm'
NewRelic::Agent.manual_start
require 'db_connection'
require 'encrypted_id'
require 'access_token'
require 'circles_user'
require 'user'
require_relative 'faye_server'

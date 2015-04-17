rack_env = ENV['RACK_ENV'] || 'development'
Bundler.require(:default, rack_env)

require 'faye'
require 'faye/redis'
require 'faye/websocket'
require 'active_record'
require 'mysql2'
require 'permessage_deflate'
require 'dotenv'
Dotenv.load ".env.#{ENV['RACK_ENV']}", '.env'

require 'logger'
$logger = Logger.new("log/#{rack_env}.log")
$logger.level = ENV['LOG_LEVEL'].to_i || Logger::DEBUG

[File.expand_path("app/models"), File.expand_path("app/logics"), File.expand_path("lib")].each do |path|
  $LOAD_PATH.unshift path
end

require 'db_connection'
require 'encrypted_id'
require 'access_token'
require 'circles_user'
require 'user'
require_relative 'faye_server'

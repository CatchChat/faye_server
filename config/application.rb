require 'faye'
require 'faye/redis'
require 'faye/websocket'
require 'active_record'
require 'mysql2'
require 'dotenv'
Dotenv.load
require_relative '../db_connection'
require_relative '../server_auth'

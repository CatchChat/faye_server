# This file is used by Rack-based servers to start the application.
require 'faye'
require 'faye/redis'
require 'faye/websocket'
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25,
           :engine  => {
             :type  => Faye::Redis,
             :host  => 'localhost',
             :port  => 6379
         })
Faye::WebSocket.load_adapter('thin')
run bayeux


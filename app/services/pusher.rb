require 'forwardable'
require 'jpush_pusher'
require 'xinge_pusher'
class Pusher
  extend Forwardable
  def_delegators :@provider, :push_to_single_account
  attr_accessor :options, :provider

  def initialize(provider, options)
    @options  = options
    @provider = provider
    provider.prepare(self)
  end
end

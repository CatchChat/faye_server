require 'forwardable'
class Sms
  extend Forwardable
  def_delegators :@provider, :send_sms
  attr_accessor :options, :provider

  def initialize(provider, options={})
    @options  = options
    @provider = provider
    provider.prepare(self)
  end
end

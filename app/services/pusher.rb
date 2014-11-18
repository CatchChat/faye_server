require 'forwardable'
class Pusher
  extend Forwardable
  def_delegators :@provider, :push_to_single_account
  attr_accessor :options, :provider

  def initialize(provider, options = {})
    @options  = options
    @provider = provider
    provider.prepare(self)
  end

  class << self
    def push_to_user(user_id, options = {})
      fail 'No current access token' unless token = AccessToken.current

      pusher = if token.company?    # Use Xinge
                 new(XingePusher.new(Settings.xinge.to_hash.symbolize_keys))
               else                 # Use JPush
                 options[:environment] = false if token.local?
                 new(JpushPusher.new(Settings.jpush.to_hash.symbolize_keys))
               end

      options[:title] = I18n.t('catch_chat') if options[:title].blank?
      pusher.push_to_single_account(options.merge(account: user_id))
    end
  end
end

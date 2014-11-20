require 'forwardable'
class Pusher
  extend Forwardable
  def_delegators :@provider, :push_to_accounts
  attr_accessor :options, :provider

  def initialize(provider, options = {})
    @options  = options
    @provider = provider
    provider.prepare(self)
  end

  class << self
    def push_to_users(user_ids, options = {})
      fail 'No current access token' unless token = AccessToken.current

      pusher = if token.company?    # Use Xinge
                 new(XingePusher.new(Settings.xinge.to_hash.symbolize_keys))
               else                 # Use JPush
                 options[:environment] = false if token.local?
                 new(JpushPusher.new(Settings.jpush.to_hash.symbolize_keys))
               end

      options[:title] = I18n.t('catch_chat') if options[:title].blank?
      pusher.push_to_accounts(options.merge(accounts: user_ids))
    end

    alias_method :push_to_user, :push_to_users
  end
end

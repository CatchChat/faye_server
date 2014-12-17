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
    def push_to_users(users, options = {})
      pusher_ids = Array(users).map(&:pusher_id)
      token = AccessToken.current
      options[:environment] = false if token && token.local?
      options[:title] = I18n.t('catch_chat') if options[:title].blank?

      [
        new(XingePusher.new(Settings.xinge.to_hash.symbolize_keys)),
        new(JpushPusher.new(Settings.jpush.to_hash.symbolize_keys))
      ].each do |pusher|
        pusher.push_to_accounts(options.merge(accounts: pusher_ids))
      end
    end

    alias_method :push_to_user, :push_to_users
  end
end

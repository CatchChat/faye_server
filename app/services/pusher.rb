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
      options = options.deep_dup
      users = Array(users)
      pusher_ids = users.map(&:pusher_id)
      token = AccessToken.current
      options[:environment] = false if token && token.local?
      options[:title] = I18n.t('catch_chat') if options[:title].blank?

      if users.size == 1
        options[:badge] = users[0].unread_messages_count.value + users[0].pending_friend_requests_count.value
      end

      results = []
      [
        new(XingePusher.new(Settings.xinge.to_hash.symbolize_keys)),
        new(JpushPusher.new(Settings.jpush.to_hash.symbolize_keys))
      ].each do |pusher|
        results << pusher.push_to_accounts(options.merge(accounts: pusher_ids))
      end

      results.all?
    end

    alias_method :push_to_user, :push_to_users
  end
end

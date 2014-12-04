require 'faraday'
require 'vanguard'
require 'virtus'
require 'nexmo'
class NexmoSms
  include Virtus.model
  attribute :key, String
  attribute :secret, String
  attribute :mobile, String
  attribute :message, String

  def initialize(keys)
    super

  end

  def prepare(sms)
    self.attributes = self.attributes.merge sms.options
  end

  def send_sms(args)
    self.attributes = self.attributes.merge args
    nexmo = Nexmo::Client.new(key: key, secret: secret)
    message_with_suffix = message + ' (Catch Chat)'
    nexmo.send_message from:  'Catch Chat',
                       to:    mobile,
                       text:  message_with_suffix
  end

end

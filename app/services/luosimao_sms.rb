require 'faraday'
require 'vanguard'
require 'virtus'
class LuosimaoSms
  include Virtus.model
  attribute :username, String
  attribute :apikey, String
  attribute :api_host, String, default: 'http://sms-api.luosimao.com'
  attribute :api_send_url, String, default: 'http://sms-api.luosimao.com/v1/send.json'
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

    message_with_suffix = message + ' 【秒视】'

    url_path = URI.parse(URI.encode(api_send_url))

    conn = Faraday.new(url: api_host) do |faraday|
      faraday.request :url_encoded
      # faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    conn.basic_auth username, apikey
    resp = conn.post url_path, mobile: mobile, message: message_with_suffix
    resp.body
  end
end

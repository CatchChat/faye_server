require 'faraday'
class LuosimaoSms
  attr_accessor :options

  def initialize(keys)
    @username = keys.fetch :username
    @apikey   = keys.fetch :apikey

    @options                   = keys
    @options[:api_host]      ||= 'http://sms-api.luosimao.com'
    @options[:api_send_url]  ||= "http://sms-api.luosimao.com/v1/send.json"
  end

  def prepare(sms)
    options.merge! sms.options
  end

  def send_sms(args)
    options.merge! args

    username     = options.fetch :username
    apikey       = options.fetch :apikey
    api_host     = options.fetch :api_host
    api_send_url = options.fetch :api_send_url
    mobile       = options.fetch :mobile
    message      = options.fetch :message
    message = message + " 【秒视】"

    url_path = URI.parse(URI.encode(api_send_url))

    conn = Faraday.new(url: api_host ) do |faraday|
      faraday.request :url_encoded
      #faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    conn.basic_auth username, apikey
    resp = conn.post url_path, {mobile: mobile, message: message} do |req|
    end
    [resp.status, resp.body]
  end
end

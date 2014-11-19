require 'faraday'
require 'vanguard'
require 'virtus'
require 'base64'
require 'securerandom'
require 'mime/types'
class UpyunCdn
  include Virtus.model
  attribute :username, String
  attribute :password, String
  attribute :http_method, String
  attribute :file_path, String
  attribute :file_length, String
  attribute :file_location, String
  attribute :content_length, Integer
  attribute :bucket, String
  attribute :notify_url, String
  attribute :api_host, String, default: 'http://v0.api.upyun.com'

  def initialize(keys)
    super
  end

  def prepare(cdn)
    self.attributes = self.attributes.merge cdn.options
  end

  def get_upload_token(args = {})
    self.attributes = self.attributes.merge args
    raise Cdn::MissingParam, "missing params for upload token" unless UPLOADVALIDATOR.call(self).valid?

    http_method    ||= 'PUT'

    sign http_method, gmt_date, "/#{bucket}#{file_path}",
         file_length, password
  end

  def get_download_token(args = {})
    self.attributes = self.attributes.merge args
    raise Cdn::MissingParam, "missing params for download token" unless DOWNLOADVALIDATOR.call(self).valid?
    http_method    ||= 'GET'
    content_length    = '0'
    sign http_method,
         gmt_date,
         "/#{bucket}#{file_path}",
         content_length, password
  end

  def upload_file(args = {})
    self.attributes = self.attributes.merge args
    raise Cdn::MissingParam, "missing params for upload file" unless UPLOADVALIDATOR.call(self).valid?
    token         = get_upload_token(args)

    url = "#{api_host}/#{bucket}#{file_path}"
    url_path = URI.parse(URI.encode(url)).path

    conn = Faraday.new(url: api_host) do |faraday|
      faraday.request :url_encoded
      # faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    resp = conn.put url_path, File.read(file_location) do |req|
      req.headers['Authorization']  = token
      req.headers['Date']           = gmt_date
      req.headers['Content-Length'] = File.read(file_location).length.to_s
    end
    resp.status
  end

  def callback_upload_file(args = {})
    self.attributes = self.attributes.merge args
    rase Cdn::MissingParam unless CALLBACKUPLOADVALIDATOR.call(self).valid?

    conn = Faraday.new(url: api_host) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      # faraday.adapter :net_http
      faraday.adapter Faraday.default_adapter
    end
    mime_type =  MIME::Types.type_for(file_location).first

    payload = {
      policy: policy,
      signature: form_api_sign,
      file: Faraday::UploadIO.new(file_location, mime_type.content_type)
    }

    resp = conn.post bucket, payload
    resp.status
  end

  private

  def form_api_sign
    Digest::MD5.hexdigest("#{policy}&#{form_api_secret}")
  end

  def policy
    hash = {
      :bucket       => bucket,
      :"save-key"   => file_path,
      :expiration   => Time.now.to_i + 600,
      :"return-url" => nil,
      :"notify-url" => notify_url
    }

    Base64.encode64(hash.to_json).gsub(/\n/,'')
  end

  def form_api_secret
    ENV['upyun_form_api_secret']
  end

  def sign(method, date, url, length, password)
    str =
      "#{method}&#{url}&#{date}&#{length}&#{Digest::MD5.hexdigest(password)}"
    #   puts sign
    "UpYun #{@username}:#{Digest::MD5.hexdigest(str)}"
  end

  def gmt_date
    @date ||= Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
  end

  DOWNLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :bucket, :file_path
  end

  UPLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :bucket, :file_path, :file_length
  end

  CALLBACKUPLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :bucket, :file_path, :notify_url
  end
end

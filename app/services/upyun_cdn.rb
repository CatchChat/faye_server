require 'faraday'
require 'base64'
require 'securerandom'
require 'mime/types'
class UpyunCdn
  attr_accessor :options

  def initialize(keys)
    @username = keys.fetch :username
    @password = keys.fetch :password

    @options = keys
    @options[:api_host] ||= 'http://v0.api.upyun.com'
  end

  def prepare(cdn)
    options.merge! cdn.options
  end

  def get_upload_token(args = {})
    verify_upload_args(args)
    options.merge! args

    o = OpenStruct.new options
    o.http_method    ||= 'PUT'

    sign o.http_method, gmt_date, "/#{o.bucket}#{o.file_path}",
         o.file_length, o.password
  end

  def get_download_token(args = {})
    verify_download_args(args)
    options.merge! args
    o = OpenStruct.new options
    o.http_method    ||= 'GET'
    o.content_length    = '0'
    sign o.http_method,
         gmt_date,
         "/#{o.bucket}#{o.file_path}",
         o.content_length, o.password
  end

  def upload_file(args = {})
    verify_upload_args(args)
    options.merge! args
    token         = get_upload_token(args)
    o = OpenStruct.new options

    url = "#{o.api_host}/#{o.bucket}#{o.file_path}"
    url_path = URI.parse(URI.encode(url)).path

    conn = Faraday.new(url: o.api_host) do |faraday|
      faraday.request :url_encoded
      # faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    resp = conn.put url_path, File.read(o.file_location) do |req|
      req.headers['Authorization']  = token
      req.headers['Date']           = gmt_date
      req.headers['Content-Length'] = File.read(o.file_location).length.to_s
    end
    resp.status
  end

  def callback_upload_file(args = {})
    verify_callback_upload_args(args)
    options.merge! args

    o = OpenStruct.new options

    conn = Faraday.new(url: o.api_host) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      #faraday.adapter :net_http
      faraday.adapter Faraday.default_adapter
    end
    mime_type =  MIME::Types.type_for(o.file_location).first

    payload = {
      policy: policy,
      signature: form_api_sign,
      file: Faraday::UploadIO.new(o.file_location, mime_type.content_type)
    }

    resp = conn.post o.bucket, payload
    resp.status
  end

  private

  def verify_download_args(args)
    [:bucket, :file_path].each do |k|
      fail "missing key #{k}" unless args.key? k
    end
  end

  def verify_upload_args(args)
    [:bucket, :file_path, :file_length].each do |k|
      fail "missing key #{k}" unless args.key? k
    end
  end

  def verify_callback_upload_args(args)
    [:bucket, :file_path,:notify_url].each do |k|
      fail "missing key #{k}" unless args.key? k
    end
  end

  def form_api_sign
    Digest::MD5.hexdigest("#{policy}&#{form_api_secret}")
  end

  def policy
    o = OpenStruct.new options
    hash = {
      :bucket => o.bucket,
      :"save-key" => o.file_path,
      :expiration => Time.now.to_i + 600,
      :"return-url" => nil,
      :"notify-url" => o.notify_url
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
end

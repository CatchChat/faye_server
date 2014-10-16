require 'faraday'
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

  def get_upload_token(args={})
    options.merge! args

    method    = options.fetch :method, 'PUT'
    bucket    = options.fetch :bucket
    file_path = options.fetch :file_path
    length    = options.fetch :file_length
    password  = options.fetch :password
    api_host  = options.fetch :api_host

    url = "#{api_host}/#{bucket}#{file_path}"
    uri = URI.parse(URI.encode(url))

    sign method, getGMTDate, "/#{bucket}#{file_path}", length, password
  end

  def get_download_token(args={})
    options.merge! args

    method    = options.fetch :method, 'GET'
    bucket    = options.fetch :bucket
    file_path = options.fetch :file_path
    length    = '0'
    password  = options.fetch :password
    sign method, getGMTDate, "/#{bucket}#{file_path}", length, password
  end

  def upload_file(args={})
    token         = get_upload_token(args)
    api_host      = options.fetch :api_host
    bucket        = options.fetch :bucket
    file_path     = options.fetch :file_path
    file_location = options.fetch :file_location

    url = "#{api_host}/#{bucket}#{file_path}"
    url_path = URI.parse(URI.encode(url))

    conn = Faraday.new(url: api_host ) do |faraday|
      faraday.request :url_encoded
      #faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    resp = conn.put url_path, File.read(file_location) do |req|
      req.headers['Authorization']  = token
      req.headers['Date']           = getGMTDate
      req.headers['Content-Length'] = File.read(file_location).length.to_s
    end
    resp.status

  end

  private

  def sign(method, date, url, length, password)

    str = "#{method}&#{url}&#{date}&#{length}&#{Digest::MD5.hexdigest(password)}"
    #   puts sign
    "UpYun #{@username}:#{Digest::MD5.hexdigest(str)}"
  end

  def getGMTDate
    @date ||= Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
  end
end

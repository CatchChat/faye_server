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

  def get_upload_token(args = {})
    verify_upload_token(args)
    options.merge! args

    o = OpenStruct.new options
    o.http_method    ||= 'PUT'
    # api_host  = options.fetch :api_host

    # url = "#{api_host}/#{bucket}#{file_path}"
    # uri = URI.parse(URI.encode(url))

    sign o.http_method, gmt_date, "/#{o.bucket}#{o.file_path}",
         o.file_length, o.password
  end

  def get_download_token(args = {})
    verify_download_token(args)
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
    verify_upload_token(args)
    token         = get_upload_token(args)
    o = OpenStruct.new options

    url = "#{o.api_host}/#{o.bucket}#{o.file_path}"
    url_path = URI.parse(URI.encode(url))

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

  private

  def verify_download_token(args)
    [:bucket, :file_path].each do |k|
      fail "missing key #{k}" unless args.key? k
    end
  end

  def verify_upload_token(args)
    [:bucket, :file_path, :file_length,
     :callback_url, :callback_body].each do |k|
      fail "missing key #{k}" unless args.key? k
    end
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

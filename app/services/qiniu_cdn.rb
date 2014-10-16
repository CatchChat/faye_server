require 'qiniu'
class QiniuCdn
  attr_accessor :options
  def initialize(keys)
    @access_key = keys.fetch :access_key
    @secret_key = keys.fetch :secret_key
    @options    = keys
    Qiniu.establish_connection! access_key: @access_key,
                                secret_key: @secret_key
  end

  def prepare(cdn)
    options.merge! cdn.options
  end

  def get_upload_token(args = {})
    verify_upload_args(args)
    options.merge! args
    o = OpenStruct.new options
    put_policy.callback_url = o.callback_url
    Qiniu::Auth.generate_uptoken(put_policy)
  end

  def put_policy
    @put_policy ||= Qiniu::Auth::PutPolicy.new(
            options.fetch(:bucket),     # 存储空间
            options.fetch(:key),        # 最终资源名，可省略，即缺省为“创建”语义
            options.fetch(:expires_in, 3600) # 相对有效期，可省略，缺省为3600秒后 uptoken 过期
        )
    @put_policy.callback_url = options.fetch :callback_url
    @put_policy.callback_body = options.fetch :callback_body
    @put_policy
  end

  def get_download_url(args)
    verify_download_args(args)
    options.merge! args
    o = OpenStruct.new options
    Qiniu::Auth.authorize_download_url(o.url)
  end

  def upload_file(args)
    options.merge! args
    file_location = options.fetch :file_location

    code, _result, _response_headers = Qiniu::Storage.upload_with_put_policy(
      put_policy, file_location, 'test-key')
    code
  end

  private

  def verify_upload_args(args)
    [:callback_url, :callback_body].each do |k|
      fail "missing key #{k}" unless args.key? k
    end
  end

  def verify_download_args(args)
    [:url].each do |k|
      fail "missing key #{k}" unless args.key? k
    end
  end
end

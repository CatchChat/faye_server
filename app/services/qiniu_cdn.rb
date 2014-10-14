require 'qiniu'
class QiniuCdn
  attr_accessor :options
  def initialize(keys)
    @access_key = keys.fetch :access_key
    @secret_key = keys.fetch :secret_key
    @options ||= {}
    Qiniu.establish_connection! access_key: @access_key,
                                secret_key: @secret_key
  end

  def prepare(cdn)
    options = cdn.options
  end

  def get_upload_token(args={})
    options.merge! args
    put_policy = get_put_policy
    put_policy.callback_url = options.fetch :callback_url
    Qiniu::Auth.generate_uptoken(put_policy)

  end

  def get_put_policy
    Qiniu::Auth::PutPolicy.new(
            options.fetch(:bucket),     # 存储空间
            options.fetch(:key),        # 最终资源名，可省略，即缺省为“创建”语义
            options.fetch(:expires_in, 3600) # 相对有效期，可省略，缺省为3600秒后 uptoken 过期
        )

  end

  def get_download_url(args)

    @options.merge! args
        url = options.fetch(:url)
    Qiniu::Auth.authorize_download_url(url)
  end

  def upload_file(args)
    options.merge! args
    file_location = options.fetch :file_location

    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(
      get_put_policy, file_location, 'test-key')
    code
  end




end

require 'qiniu'
require 'vanguard'
require 'virtus'

require 'vanguard'
module QiniuValidator
  DOWNLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :url
  end

  UPLOADVALIDATOR = Vanguard::Validator.build do
      validates_presence_of :bucket, :key, :callback_url, :callback_body
  end
end

class QiniuCdn
  include Virtus.model
  attribute :access_key, String
  attribute :secret_key, String
  attribute :bucket, String
  attribute :key, String
  attribute :url, String
  attribute :expires_in, Integer, default: 3600
  attribute :download_expires_in, Integer, default: 3600*24
  attribute :callback_url, String
  attribute :callback_body, String
  attribute :file_location, String
  attribute :x_vars, Hash[Symbol => String]
  def initialize(keys)
    super
    Qiniu.establish_connection! access_key: access_key,
                                secret_key: secret_key
  end

  def prepare(cdn)
    self.attributes = self.attributes.merge cdn.options
  end

  def get_upload_token(args = {})
    self.attributes = self.attributes.merge args
    raise Cdn::MissingParam, "missing params for upload token" unless QiniuValidator::UPLOADVALIDATOR.call(self).valid?

    put_policy.callback_url = callback_url
    Qiniu::Auth.generate_uptoken(put_policy)
  end

  def get_download_url(args)
    self.attributes = self.attributes.merge args
    raise Cdn::MissingParam, "missing params for download url" unless QiniuValidator::DOWNLOADVALIDATOR.call(self).valid?
    Qiniu::Auth.authorize_download_url(url, expires_in: download_expires_in)
  end

  def upload_file(args)
    self.attributes = self.attributes.merge args

    code, _result, _response_headers = Qiniu::Storage.upload_with_put_policy(
      put_policy, file_location, key, x_vars)
    code
  end


  private
  def put_policy
    @put_policy ||= Qiniu::Auth::PutPolicy.new(
            bucket,     # 存储空间
            key,        # 最终资源名，可省略，即缺省为“创建”语义
            expires_in || 3600 # 相对有效期，可省略，缺省为3600秒后 uptoken 过期
        )
    @put_policy.callback_url  = callback_url
    @put_policy.callback_body = callback_body
    @put_policy
  end
end

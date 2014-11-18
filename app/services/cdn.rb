require 'forwardable'
require 'qiniu_cdn'
require 'upyun_cdn'
require 's3_cdn'
class Cdn
  extend Forwardable
  def_delegators :@provider, :get_upload_token, :callback_upload_file,
                 :get_download_token, :get_download_url, :upload_file,
                 :get_upload_form_url_fields, :sqs_receive, :sqs_poll
  attr_accessor :options, :provider
  def initialize(provider, options={})
    @options  = options
    @provider = provider
    provider.prepare(self)
  end
end

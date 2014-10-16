require 'forwardable'
require 'qiniu_cdn'
require 'upyun_cdn'
class Cdn
  extend Forwardable
  def_delegators :@provider, :get_upload_token,
                 :get_download_token, :get_download_url, :upload_file
  attr_accessor :options, :provider
  def initialize(provider, options)
    @options  = options
    @provider = provider
    provider.prepare(self)
  end
end

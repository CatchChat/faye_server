module QiniuHelper
  def self.client

    qiniu_client = QiniuCdn.new init_hash
    Cdn.new(qiniu_client)
  end

  def self.avatar_client
    qiniu_client = QiniuCdn.new init_hash.merge(
      bucket: ENV["qiniu_attachment_public_bucket"],
      callback_url: ENV["qiniu_public_callback_url"]
    )
    Cdn.new(qiniu_client)
  end
  def self.url(key)
    bucket = ENV["qiniu_attachment_bucket"]
    "http://#{bucket}.qiniudn.com/#{key}"
  end

  def self.public_url(key)
    bucket = ENV["qiniu_attachment_public_bucket"]
    "http://#{bucket}.qiniudn.com/#{key}"
  end
  private
  def self.init_hash
    access_key    = ENV["qiniu_access_key"]
    secret_key    = ENV["qiniu_secret_key"]
    callback_url  = ENV["qiniu_callback_url"]
    callback_body = ENV["qiniu_callback_body"]
    bucket        = ENV["qiniu_attachment_bucket"]

    {
      access_key:     access_key,
      secret_key:     secret_key,
      callback_url:   callback_url,
      callback_body:  callback_body,
      bucket:         bucket
    }
  end
end

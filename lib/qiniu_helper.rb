module QiniuHelper
  def self.client

    access_key    = ENV["qiniu_access_key"]
    secret_key    = ENV["qiniu_secret_key"]
    callback_url  = ENV["qiniu_callback_url"]
    callback_body = ENV["qiniu_callback_body"]
    bucket        = ENV["qiniu_attachment_bucket"]

    init_hash = { access_key:     access_key,
                  secret_key:     secret_key,
                  callback_url:   callback_url,
                  callback_body:  callback_body,
                  bucket:         bucket,

                }
    qiniu_client = QiniuCdn.new init_hash
    Cdn.new(qiniu_client)
  end

end

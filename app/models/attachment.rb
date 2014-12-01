class Attachment < ActiveRecord::Base
  has_and_belongs_to_many :messages

  validates :file, presence: true

  def download_url(expires_in=3600*24)
    raise 'provider is not supported yet' unless storage == 'qiniu'
    bucket        = ENV["qiniu_attachment_bucket"]

    cdn = QiniuHelper.client
    url = "http://#{bucket}.qiniudn.com/#{file}"
    [expires_in, cdn.get_download_url(url: url, key: file, download_expires_in: expires_in)]
  end

  def fallback_url(expires_in=3600*24)
    raise 'provider is not supported yet' unless fallback_storage == 's3'
    cdn = S3Helper.client
    [expires_in, cdn.get_download_url(key: fallback_file, download_expires_in: expires_in)]
  end
end

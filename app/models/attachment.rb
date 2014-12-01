class Attachment < ActiveRecord::Base
  has_and_belongs_to_many :messages

  validates :file, presence: true

  def download_url
    raise 'provider is not supported yet' unless storage == 'qiniu'
    bucket        = ENV["qiniu_attachment_bucket"]

    cdn = QiniuHelper.client
    url = "http://#{bucket}.qiniudn.com/#{file}"
    cdn.get_download_url url: url, key: file
  end

  def fallback_url
    raise 'provider is not supported yet' unless fallback_storage == 's3'
    cdn = S3Helper.client
    cdn.get_download_url key: fallback_file
  end
end

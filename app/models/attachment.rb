class Attachment < ActiveRecord::Base

  class AttachmentParsingError < RuntimeError; end
  has_and_belongs_to_many :messages

  validates :file, presence: true

  before_destroy :queue_to_delete_storage

  def download_url_with_timer(expires_in=3600*24)
    return [expires_in, nil] unless storage == 'qiniu'
    bucket        = ENV["qiniu_attachment_bucket"]

    cdn = QiniuHelper.client
    url = "http://#{bucket}.qiniudn.com/#{file}"
    [cdn.get_download_url(url: url, key: file, download_expires_in: expires_in), expires_in]
  end

  def fallback_url_with_timer(expires_in=3600*24)
    return [expires_in, nil] unless fallback_storage == 's3'
    cdn = S3Helper.client
    [cdn.get_download_url(key: fallback_file, download_expires_in: expires_in), expires_in]
  end

  def self.create_by_parsing_qiniu_private_url(url)
    uri = URI.parse url
    host = uri.host
    raise AttachmentParsingError, 'only work for qiniu url' unless host =~ /qiniudn.com/
    bucket = host.split('.').first
    path = uri.path
    key = path[1..-1]
    raise AttachmentParsingError, "must set to the same bucket before parsing" unless bucket == ENV["qiniu_attachment_bucket"]

    self.create! storage: 'qiniu', file: key
  end

  def queue_to_delete_storage
      return if reserved
      DeleteAttachmentsJob.perform_async attributes.except(*%w{updated_at created_at})

  end
end

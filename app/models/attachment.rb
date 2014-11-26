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
end

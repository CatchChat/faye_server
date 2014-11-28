class AttachmentTransfer
  def self.transfer_s3(attachment)
    return if attachment.fallback_file.present?
    return unless attachment.storage == 'qiniu'

    qiniu_client = QiniuHelper.client
    url = qiniu_client.get_download_url url: QiniuHelper.url(attachment.file)

    uri = URI(url)

    t = Tempfile.new 'download'
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      http.request request do |response|
        open t.path, 'w' do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
    s3_client = S3Helper.client

    code = s3_client.upload_file file_location: t.path,
                                           key: attachment.file
    raise 'transfer failed' unless code == 204

    attachment.fallback_storage == 's3'
    attachment.fallback_file = attachment.file
    attachment.save
  end
end
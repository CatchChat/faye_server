class TransferAttachmentsJob < ActiveJob::Base
  queue_as :attachments

  def perform(*args)
    id = args["id"].to_i
    raise "attachment not found" unless attachment = Attachment.find(id)
    AttachmentTransfer.transfer_s3 attachment
  rescue => e
    puts e.message
  end
end

class TransferAttachmentsJob
  include Sidekiq::Worker
  sidekiq_options queue: :attachments, :retry => 3

  def perform(args)
    id = args["id"].to_i
    attachment = Attachment.find(id)
    AttachmentTransfer.transfer_s3 attachment
  end
end

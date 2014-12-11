class DeleteAttachmentsJob
  include Sidekiq::Worker
  sidekiq_options queue: :delete_attachments, :retry => 3

  def perform(args)
    id = args["id"].to_i
    attachment = Attachment.find(id)
    AttachmentTransfer.delete attachment
  end
end

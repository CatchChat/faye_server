require 'ostruct'
class DeleteAttachmentsJob
  include Sidekiq::Worker
  sidekiq_options queue: :delete_attachments, :retry => 3

  def perform(args)
    attachment = OpenStruct.new args
    AttachmentTransfer.delete attachment
  end
end

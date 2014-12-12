class SendOfficialMessageJob
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  # recipient is only user
  def perform(sender_id, recipient_id, parent_id = nil)
    sender = User.find(sender_id)
    recipient = User.find(recipient_id)
    parent = Message.find_by(id: parent_id) if parent_id
    message = Message.create_by_official_message!(sender, recipient, parent)
    MessageNotificationJob.perform_async(message.id)
  end
end

class SendOfficialMessageJob
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  # recipient is only user
  def perform(sender_id, recipient_id)
    sender = User.find(sender_id)
    recipient = User.find(recipient_id)
    message = Message.create_by_official_message!(sender, recipient)
    message.mark_as_unread!
    MessageNotificationJob.perform_async(message.id)
  end
end

class MessageNotificationJob
  include Sidekiq::Worker
  sidekiq_options queue: :message_notification, :retry => 3

  def perform(message_id)
    Message.find(message_id).push_notification
  end
end

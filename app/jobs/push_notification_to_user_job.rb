class PushNotificationToUserJob
  include Sidekiq::Worker
  sidekiq_options queue: :push_notification_to_user, :retry => 3

  def perform(user_id, options)
    Pusher.push_to_user(user_id, options)
  end
end

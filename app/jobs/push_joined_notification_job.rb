class PushJoinedNotificationJob
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform(user_id)
    User.find(user_id).push_joined_notification
  end
end

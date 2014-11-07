module FriendRequestCallbacks
  extend ActiveSupport::Concern

  included do
    # after_save :touch_received_friend_requests_updated_at_for_friend
    # after_destroy :touch_received_friend_requests_updated_at_for_friend
  end

  private

  def touch_received_friend_requests_updated_at_for_friend
    friend.received_friend_requests_updated_at = Time.zone.now.to_i
  end
end

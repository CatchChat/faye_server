module FriendshipCallbacks
  extend ActiveSupport::Concern

  included do
    after_create :incr_friends_count_for_user
    after_destroy :decr_friends_count_for_user
    # after_save :touch_friendships_updated_at_for_user
    # after_destroy :touch_friendships_updated_at_for_user
  end

  def incr_friends_count_for_user
    user.friends_count.incr
  end

  def decr_friends_count_for_user
    user.friends_count.decr
  end

  def touch_friendships_updated_at_for_user
    user.friendships_updated_at = Time.zone.now.to_i
  end
end

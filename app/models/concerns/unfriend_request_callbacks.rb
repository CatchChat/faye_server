module UnfriendRequestCallbacks
  extend ActiveSupport::Concern

  included do
    after_create :remove_friend
  end

  def remove_friend
    user.friendships.find_by(friend_id: friend_id).try(:destroy)
  end
end

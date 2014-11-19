module UnfriendRequestCallbacks
  extend ActiveSupport::Concern

  included do
    after_create :unfriend
  end

  private

  def unfriend
    User.unfriend(user_id, friend_id)
  end
end

class UnfriendRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  after_create :remove_friend

  def remove_friend
    user.friendships.find_by(friend_id: friend_id).try(:destroy)
  end
end

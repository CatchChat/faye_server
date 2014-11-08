class Friendship < ActiveRecord::Base
  include FriendshipCallbacks

  belongs_to :user
  belongs_to :friend, class_name: 'User'
  has_many :friendships_groups
  has_many :groups, through: :friendships_groups

  acts_as_list scope: [:user_id]
  default_scope { order("#{self.table_name}.position") }

  validates :user_id, :friend_id, presence: true
  # TODO validate contact_name and remarked_name

  def name
    remarked_name.presence || contact_name.presence || friend.nickname || friend.username
  end
end

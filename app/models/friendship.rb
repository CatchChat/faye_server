class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'
  has_many :friendships_groups, dependent: :destroy
  has_many :groups, through: :friendships_groups

  acts_as_list scope: [:user_id]
  default_scope { order("#{self.table_name}.position") }

  validates :user_id, :friend_id, presence: true
  # TODO validate contact_name and remarked_name

  def name
    remarked_name.presence || contact_name.presence || friend.name
  end

  def self.create_friendships(user, friend)
    user_id   = user.is_a?(User) ? user.id : user
    friend_id = friend.is_a?(User) ? friend.id : friend
    Friendship.transaction do
      begin
        # TODO: Add contact_name after find contacts
        Friendship.create!(user_id: user_id, friend_id: friend_id)
        Friendship.create!(friend_id: user_id, user_id: friend_id)
        return true
      rescue => ex
        logger.debug "===> #{ex}"
        raise ActiveRecord::Rollback
      end
    end
    false
  end

  def self.unfriend(user, friend)
    user_id   = user.is_a?(User) ? user.id : user
    friend_id = friend.is_a?(User) ? friend.id : friend
    Friendship.where(
      '(user_id = :user_id AND friend_id = :friend_id) OR (user_id = :friend_id AND friend_id = :user_id)',
      user_id: user_id, friend_id: friend_id
    ).destroy_all
  end
end

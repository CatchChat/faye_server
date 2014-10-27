class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  acts_as_list scope: [:user_id]
  default_scope { order("#{self.table_name}.position") }

  validates :user_id, :friend_id, presence: true
end

class Group < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_many :friendships_groups
  has_many :friendships, through: :friendships_groups
  has_many :friends, through: :friendships
  has_many :messages, as: :recipient

  acts_as_list scope: [:owner_id]
  default_scope { order("#{self.table_name}.position") }

  validates :owner_id, :name, presence: true
  validates :name, uniqueness: { scope: :owner_id, allow_blank: true }
end

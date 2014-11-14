class FriendshipsGroup < ActiveRecord::Base
  belongs_to :friendship
  belongs_to :group

  acts_as_list scope: [:group_id]
  default_scope { order("#{self.table_name}.position") }

  validates :friendship_id, :group_id, presence: true
  validates :friendship_id, uniqueness: { scope: :group_id, allow_blank: true }
end

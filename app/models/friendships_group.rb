class FriendshipsGroup < ActiveRecord::Base
  belongs_to :friendship
  belongs_to :group

  acts_as_list scope: [:group_id]
  default_scope { order("#{self.table_name}.position") }
end

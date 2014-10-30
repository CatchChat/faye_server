class Group < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'

  acts_as_list scope: [:owner_id]
  default_scope { order("#{self.table_name}.position") }

  validates :owner_id, :name, presence: true
end
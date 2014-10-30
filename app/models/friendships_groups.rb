class FriendshipsGroups < ActiveRecord::Base
  self.table_name = 'friendships_groups'
  belongs_to :group
  belongs_to :friend_ship
end

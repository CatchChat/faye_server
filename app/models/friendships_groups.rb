class FriendshipsGroups < ActiveRecord::Base
  belongs_to :group
  belongs_to :friend_ship
end

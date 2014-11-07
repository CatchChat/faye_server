class UnfriendRequest < ActiveRecord::Base
  include UnfriendRequestCallbacks

  belongs_to :user
  belongs_to :friend, class_name: 'User'
end

class CreateFriendRequests < ActiveRecord::Migration
  def change
    create_table :friend_requests do |t|
      t.string :user
      t.string :friend
      t.string :state

      t.timestamps
    end
  end
end

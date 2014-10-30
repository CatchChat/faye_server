class CreateFriendRequests < ActiveRecord::Migration
  def change
    create_table :friend_requests do |t|
      t.references :user, index: true
      t.references :friend, index: true
      t.string :state

      t.timestamps
    end
  end
end

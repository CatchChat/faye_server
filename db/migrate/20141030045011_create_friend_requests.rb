class CreateFriendRequests < ActiveRecord::Migration
  def change
    create_table :friend_requests do |t|
      t.references :user, index: true
      t.integer :friend_id
      t.string :state

      t.timestamps
    end
    add_index :friend_requests, :friend_id
  end
end

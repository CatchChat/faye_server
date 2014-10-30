class CreateFriendRequests < ActiveRecord::Migration
  def change
    create_table :friend_requests do |t|
      t.references :user, index: true
      t.references :friend, index: true
      t.integer :state, null: false, default: 0 # pending state

      t.timestamps
    end
  end
end

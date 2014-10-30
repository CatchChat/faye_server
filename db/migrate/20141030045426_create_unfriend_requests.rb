class CreateUnfriendRequests < ActiveRecord::Migration
  def change
    create_table :unfriend_requests do |t|
      t.references :user, index: true
      t.integer :friend_id

      t.timestamps
    end
    add_index :unfriend_requests, :friend_id
  end
end

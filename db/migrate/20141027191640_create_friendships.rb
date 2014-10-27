class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :user, index: true
      t.integer :friend_id
      t.string :contact_name
      t.string :remarked_name
      t.integer :position

      t.timestamps
    end
    add_index :friendships, :friend_id
    add_index :friendships, :position
  end
end

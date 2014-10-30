class CreateFriendshipsGroups < ActiveRecord::Migration
  def change
    create_table :friendships_groups do |t|
      t.references :group, index: true
      t.references :friend_ship, index: true
      t.integer :position

      t.timestamps
    end
    add_index :friendships_groups, :group_id
    add_index :friendships_groups, :friend_ship_id
  end
end

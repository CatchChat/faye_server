class RenameUsersNodeIdToPusherId < ActiveRecord::Migration
  def change
    remove_index :users, :node_id
    rename_column :users, :node_id, :pusher_id
    add_index :users, :pusher_id, unique: true, length: 191
  end
end

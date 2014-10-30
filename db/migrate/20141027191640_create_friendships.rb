class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :user, index: true
      t.references :friend, index: true
      t.string :contact_name
      t.string :remarked_name
      t.integer :position

      t.timestamps
    end
    add_index :friendships, :position
  end
end

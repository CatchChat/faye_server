class CreateFriendshipsGroups < ActiveRecord::Migration
  def change
    create_table :friendships_groups do |t|
      t.references :group, index: true
      t.references :friendship, index: true

      t.timestamps
    end
  end
end

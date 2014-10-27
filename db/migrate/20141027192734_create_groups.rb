class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.integer :owner_id
      t.string :name
      t.integer :position

      t.timestamps
    end
    add_index :groups, :owner_id
    add_index :groups, :position
  end
end

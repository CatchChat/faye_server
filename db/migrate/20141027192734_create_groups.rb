class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.references :owner, index: true
      t.string :name
      t.integer :position

      t.timestamps
    end
    add_index :groups, :position
  end
end

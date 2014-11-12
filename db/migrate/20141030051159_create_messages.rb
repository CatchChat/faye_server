class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :sender, index: true
      t.references :recipient, polymorphic: true, index: true
      t.string :media_type
      t.text :text_content
      t.integer :parent_id
      t.integer :state
      t.float :longitude
      t.float :latitude

      t.timestamps
    end
    add_index :messages, :parent_id
  end
end

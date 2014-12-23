class CreateOfficialMessages < ActiveRecord::Migration
  def change
    create_table :official_messages do |t|
      t.integer :media_type
      t.string :text_content
      t.float :longitude
      t.float :latitude
      t.integer :battery_level, null: false, default: 50

      t.timestamps
    end
  end
end

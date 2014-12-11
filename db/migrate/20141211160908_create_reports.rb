class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.references :whistleblower, index: true
      t.references :message, index: true

      t.references :sender, index: true
      t.references :recipient, polymorphic: true
      t.integer :media_type, null: false, default: Message.media_types[:text]
      t.text :text_content
      t.integer :parent_id, null: false, default: 0
      t.integer :state
      t.float :longitude
      t.float :latitude
      t.integer :battery_level, null: false, default: 50

      t.index [:recipient_id, :recipient_type], length: { recipient_type: 191 }
      t.timestamps
    end
  end
end

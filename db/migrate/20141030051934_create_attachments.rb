class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string  :storage
      t.string  :file
      t.string  :fallback_storage
      t.string  :fallback_file
      t.boolean :public, default: false, null: false

      t.timestamps
    end
    add_index :attachments, :file, length: 191
    add_index :attachments, :fallback_file, length: 191
  end
end

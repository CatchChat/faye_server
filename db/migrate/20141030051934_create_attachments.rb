class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :storage
      t.string :file
      t.string :fallback_storage
      t.string :fallback_file

      t.timestamps
    end
  end
end

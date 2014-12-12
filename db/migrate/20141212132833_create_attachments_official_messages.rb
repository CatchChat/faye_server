class CreateAttachmentsOfficialMessages < ActiveRecord::Migration
  def change
    create_table :attachments_official_messages do |t|
      t.references :attachment, index: true
      t.references :official_message, index: true

      t.timestamps
    end
  end
end

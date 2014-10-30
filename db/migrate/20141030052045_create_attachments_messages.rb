class CreateAttachmentsMessages < ActiveRecord::Migration
  def change
    create_table :attachments_messages do |t|
      t.references :message, index: true
      t.references :attachment, index: true

      t.timestamps
    end
  end
end

class CreateAttachmentsReports < ActiveRecord::Migration
  def change
    create_table :attachments_reports do |t|
      t.references :attachment, index: true
      t.references :report, index: true

      t.timestamps
    end
  end
end

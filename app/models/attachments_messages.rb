class AttachmentsMessages < ActiveRecord::Base
  self.table_name = 'attachments_messages'
  belongs_to :message
  belongs_to :attachment
end

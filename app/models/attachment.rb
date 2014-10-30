class Attachment < ActiveRecord::Base
  has_many :attachments_messages, class_name: AttachmentsMessages
  has_many :messages, through: :attachments_messages
end

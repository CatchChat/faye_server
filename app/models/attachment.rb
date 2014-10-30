class Attachment < ActiveRecord::Base
  has_many :attachments_messages, class_name: 'AttachmentsMessage'
  has_many :messages, through: :attachments_messages
end

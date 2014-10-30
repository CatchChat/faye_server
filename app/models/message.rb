class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, polymorphic: true
  has_many :attachments_messages, class_name: 'AttachmentsMessage'
  has_many :attachments, through: :attachments_messages
end

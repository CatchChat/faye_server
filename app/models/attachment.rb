class Attachment < ActiveRecord::Base
  has_many :attachments_messages
  has_many :messages, through: :attachments_messages
end

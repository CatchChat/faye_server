class Message < ActiveRecord::Base
  belongs_to :sender, class_name: User
  belongs_to :recipient, polymorphic: true
  has_many :attachments_messages
  has_many :attachments, through: :attachments_messages

end

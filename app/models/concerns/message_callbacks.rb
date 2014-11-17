module MessageCallbacks
  extend ActiveSupport::Concern

  included do
    before_validation :assign_media_type, if: -> { media_type.blank? }
    before_validation :build_attachments, if: -> { attachment_file.present? }, on: :create
    before_validation :build_individual_recipients, on: :create
  end

  def assign_media_type
    self.media_type = self.class.detect_message_type(attachment_file)
  end

  def build_attachments
    [attachments.build(file: attachment_file, storage: attachment_storage)]
  end

  def build_individual_recipients
    if self.recipient_type == 'Group'
      self.recipient.friendships.map do |friendships|
        self.individual_recipients.build(user_id: friendship.friend_id)
      end
    else
      [self.individual_recipients.build(user_id: self.recipient_id)]
    end
  end
end

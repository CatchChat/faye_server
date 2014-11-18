module MessageCallbacks
  extend ActiveSupport::Concern

  included do
    before_validation :assign_media_type, if: -> { media_type.blank? }
  end

  def assign_media_type
    self.media_type = self.class.detect_message_type(attachment_file)
  end
end

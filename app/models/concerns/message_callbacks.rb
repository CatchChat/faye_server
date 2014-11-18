module MessageCallbacks
  extend ActiveSupport::Concern

  included do
    before_validation :assign_media_type
  end

  def assign_media_type
    self.media_type ||= Message.media_types[:text]
  end
end

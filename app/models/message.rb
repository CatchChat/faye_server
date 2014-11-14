class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, polymorphic: true
  has_and_belongs_to_many :attachments, dependent: :destroy
  has_many :individual_recipients, dependent: :destroy

  enum media_type: [:image, :video, :text]

  validates :sender_id, :recipient_id, :recipient_type, :media_type, presence: true
  validates :recipient_type, inclusion: { in: %w(User Group), allow_blank: true }

  STATES = { unread: 1, read: 2 }.freeze
  state_machine :state, initial: :unread do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :mark_as_read do
      transition unread: :read
    end
  end

  def self.detect_message_type(file_url)
    extname = File.extname(file_url.to_s).downcase

    if Settings.attachment_formats.video.include?(extname)
      media_types[:video]
    elsif Settings.attachment_formats.image.include?(extname)
      media_types[:image]
    else
      media_types[:text]
    end
  end
end

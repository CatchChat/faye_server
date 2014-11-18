class Message < ActiveRecord::Base
  include MessageCallbacks

  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, polymorphic: true
  has_and_belongs_to_many :attachments, dependent: :destroy
  has_many :individual_recipients, dependent: :destroy

  scope :draft, -> { where(table_name => { state: STATES[:draft] }) }

  enum media_type: %i(text photo video)

  validates :sender_id, :recipient_id, :recipient_type, :media_type, presence: true
  validates :recipient_type, inclusion: { in: %w(User Group), allow_blank: true }

  STATES = { draft: 1, unread: 2, read: 3 }.freeze
  state_machine :state, initial: :draft do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :mark_as_unread do
      transition draft: :unread
    end

    event :mark_as_read do
      transition unread: :read
    end

    after_transition draft: :unread, do: :create_individual_recipients
  end

  def self.detect_message_type(file_url)
    extname = File.extname(file_url.to_s).downcase

    if Settings.attachment_formats.video.include?(extname)
      media_types[:video]
    elsif Settings.attachment_formats.image.include?(extname)
      media_types[:photo]
    else
      media_types[:text]
    end
  end

  private

  def create_individual_recipients
    if self.recipient_type == 'Group'
      self.recipient.friendships.map do |friendship|
        self.individual_recipients.build(user_id: friendship.friend_id)
      end
    else
      [self.individual_recipients.build(user_id: self.recipient_id)]
    end

    self.save!
  end
end

class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, polymorphic: true
  has_and_belongs_to_many :attachments, dependent: :destroy
  has_many :individual_recipients, dependent: :destroy
  belongs_to :parent, class_name: 'Message', foreign_key: :parent_id

  scope :draft, -> { where(table_name => { state: STATES[:draft] }) }

  enum media_type: %i(text image video)

  validates :sender_id, :recipient_id, :recipient_type, :media_type, presence: true
  validates :recipient_type, inclusion: { in: %w(User Group), allow_blank: true }
  validates :battery_level, inclusion: { in: 0..100 }

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
    after_transition unread: :read, do: :delete_attachments_storage
  end

  def push_notification
    individual_recipients.includes(:user).each do |individual_recipient|
      Pusher.push_to_user(
        individual_recipient.user,
        content: I18n.t(
          'notification.sent_message_to_you',
          friend_name: sender.name_by_friend(individual_recipient.user),
          media_type: Message.human_attribute_name(media_type)
        ),
        extras: { type: 'message', subtype: self.media_type }
      )
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

  # recipient is group
  def group_message?
    recipient_type == Group.name
  end

  # recipient is user
  def direct_message?
    recipient_type == User.name
  end

  def self.create_by_official_message!(sender, recipient, parent = nil)
    parent_id = parent ? parent.id : 0
    official_message = OfficialMessage.order('RAND()').limit(1).first
    message = if official_message
                sender.messages.create!(
                  recipient: recipient,
                  media_type: official_message.media_type,
                  text_content: official_message.text_content,
                  longitude: official_message.longitude,
                  latitude: official_message.latitude,
                  battery_level: official_message.battery_level,
                  parent_id: parent_id,
                  attachments: official_message.attachments
                )
              else
                sender.messages.create!(
                  recipient: recipient,
                  text_content: I18n.t('welcome_message'),
                  parent_id: parent_id
                )
              end
    message.mark_as_unread!
    message
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

  def delete_attachments_storage
    attachments.map(&:queue_to_delete_storage)
  end
end

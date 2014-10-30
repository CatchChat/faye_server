class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, polymorphic: true
  has_many :attachments_messages
  has_many :attachments, through: :attachments_messages
  has_many :individual_recipients

  STATES = { unread: 0, read: 1 }.freeze

  state_machine :state, initial: :unread do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :read do
      transition unread: :read
    end
  end
end

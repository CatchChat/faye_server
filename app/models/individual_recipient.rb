class IndividualRecipient < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  scope :unread, -> { where.not(self.table_name => { state: STATES[:read] }) }

  attr_accessor :skip_update_message_state

  STATES = { sent: 1, delivered: 2, read: 3 }.freeze
  state_machine :state, initial: :sent do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :deliver do
      transition sent: :delivered
    end

    event :mark_as_read do
      transition [:sent, :delivered] => :read
    end

    after_transition [:sent, :delivered] => :read, do: :update_message_state
  end

  def update_message_state
    return if skip_update_message_state

    unless self.class.unread.exists?(message_id: message_id, user_id: user_id)
      message.mark_as_read
    end

    true
  end
end

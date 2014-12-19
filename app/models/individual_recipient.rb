class IndividualRecipient < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  scope :unread, -> { where.not(self.table_name => { state: STATES[:read] }) }

  attr_accessor :skip_update_message_state

  after_create :update_counters

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

    after_transition [:sent, :delivered] => :read, do: [:update_message_state, :update_counters]
  end

  private

  def update_message_state
    return if skip_update_message_state

    if self.class.unread.where(message_id: message_id).count == 0
      message.mark_as_read
    end

    true
  end

  def update_counters
    if self.sent?
      User.increment_counter(:unread_messages_count, self.user_id)
    elsif self.read?
      User.decrement_counter(:unread_messages_count, self.user_id)
    end
  end
end

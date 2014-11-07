class IndividualRecipient < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  STATES = { sent: 1, delivered: 2, read: 3 }.freeze

  state_machine :state, initial: :sent do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :deliver do
      transition sent: :delivered
    end

    event :mark_as_read do
      transition delivered: :read
    end
  end
end

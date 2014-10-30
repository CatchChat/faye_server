class IndividualRecipient < ActiveRecord::Base
  belongs_to :message
  belongs_to :user

  state_machine :state, initial: :send do
    event :delivered do
      transition send: :delivered
    end

    event :read do
      transition delivered: :read
    end

    state :send,      value: 0
    state :delivered, value: 1
    state :read,      value: 2
  end
end

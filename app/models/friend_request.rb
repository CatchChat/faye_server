class FriendRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  STATES = { pending: 0, accepted: 1, rejected: 2, blocked: 3 }.freeze

  state_machine :state, initial: :pending do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :accepted do
      transition pending: :accepted
    end

    event :rejected do
      transition pending: :rejected
    end

    event :blocked do
      transition pending: :blocked
    end
  end
end

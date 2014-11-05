class FriendRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, :friend_id, presence: true
  validates :friend_id, uniqueness: { scope: [:user_id, :state], allow_blank: true, if: ->(friend_request) { friend_request.pending? } }

  STATES = { pending: 0, accepted: 1, rejected: 2, blocked: 3 }.freeze

  STATES.each do |state, value|
    scope state, -> { where(self.table_name => { state: value }) }
  end

  state_machine :state, initial: :pending do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    event :accept do
      transition pending: :accepted
    end

    event :reject do
      transition pending: :rejected
    end

    event :block do
      transition pending: :blocked
    end
  end
end

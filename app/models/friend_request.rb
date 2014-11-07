class FriendRequest < ActiveRecord::Base
  include FriendRequestCallbacks

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, :friend_id, presence: true
  validates :friend_id, uniqueness: { scope: [:user_id, :state], allow_blank: true, if: ->(friend_request) { friend_request.pending? } }

  scope :by_state, -> (state) { where(self.table_name => { state: state }) }

  STATES = { pending: 1, accepted: 2, rejected: 3, blocked: 4 }.freeze

  STATES.each do |state, value|
    scope state, -> { where(self.table_name => { state: value }) }
  end

  state_machine :state, initial: :pending do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    after_transition pending: :accepted, do: :add_friend

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

  def add_friend
    user.friends << friend
  end
end

class FriendRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, :friend_id, presence: true
  validates :friend_id, uniqueness: { scope: [:user_id, :state], allow_blank: true, if: ->(friend_request) { friend_request.pending? } }

  after_create :update_counters

  STATES = { pending: 1, accepted: 2, rejected: 3, blocked: 4 }.freeze
  STATES.each do |state, value|
    scope state, -> { where(self.table_name => { state: value }) }
  end

  state_machine :state, initial: :pending do
    STATES.each do |state_name, value|
      state state_name, value: value
    end

    after_transition pending: :accepted, do: :create_friendships!
    after_transition pending: any, do: :update_counters

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

  def create_friendships!
    unless Friendship.create_friendships(user, friend)
      fail 'Create friendships error'
    end
  end

  private

  def update_counters
    if self.pending?
      User.increment_counter(:pending_friend_requests_count, self.friend_id)
    else
      User.decrement_counter(:pending_friend_requests_count, self.friend_id)
    end
  end
end

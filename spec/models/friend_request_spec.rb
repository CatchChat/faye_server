require 'rails_helper'
require 'timecop'

RSpec.describe FriendRequest, :type => :model do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  it '#create_friendships!' do
    allow(Friendship).to receive(:create_friendships).with(user, friend) { true }
    friend_request = FriendRequest.create!(user: user, friend: friend)
    expect { friend_request.create_friendships! }.to_not raise_error
    friend_request.destroy

    allow(Friendship).to receive(:create_friendships).with(user, friend) { false }
    friend_request = FriendRequest.create!(user: user, friend: friend)
    expect { friend_request.create_friendships! }.to raise_error
  end

  it 'Should create friendships after accept' do
    friend_request = FriendRequest.create!(user: user, friend: friend)
    allow(Friendship).to receive(:create_friendships).with(user, friend) { true }
    friend_request.accept!
  end

  context '#update_counters' do

    it 'increment counters if state is pending' do
      count = friend.pending_friend_requests_count.value
      user.friend_requests.create!(friend: friend)
      expect(friend.pending_friend_requests_count.value).to eq count + 1
    end

    it 'decrement counters if state from pending to accepted' do
      friend_request = user.friend_requests.create!(friend: friend)
      count = friend.pending_friend_requests_count.value
      friend_request.accept!
      expect(friend.pending_friend_requests_count.value).to eq count - 1
    end

    it 'decrement counters if state from pending to rejected' do
      friend_request = user.friend_requests.create!(friend: friend)
      count = friend.pending_friend_requests_count.value
      friend_request.reject!
      expect(friend.pending_friend_requests_count.value).to eq count - 1
    end

    it 'decrement counters if state from pending to blocked' do
      friend_request = user.friend_requests.create!(friend: friend)
      count = friend.pending_friend_requests_count.value
      friend_request.block!
      expect(friend.pending_friend_requests_count.value).to eq count - 1
    end
  end
end

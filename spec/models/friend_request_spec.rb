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
end

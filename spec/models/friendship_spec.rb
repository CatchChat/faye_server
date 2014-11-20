require 'rails_helper'
require 'timecop'

RSpec.describe Friendship, :type => :model do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  it '.create_friendships' do
    expect(Friendship.create_friendships(user, friend)).to eq true
    expect(user.friends).to include friend
    expect(friend.friends).to include user
  end

  it '.unfriend' do
    expect(Friendship.create_friendships(user, friend)).to eq true
    expect(user.friends).to include friend
    expect(friend.friends).to include user
    Friendship.unfriend(user, friend)
    expect(user.friends).to_not include friend
    expect(friend.friends).to_not include user
  end

  it '#name' do
    expect(Friendship.create_friendships(user, friend)).to eq true
    friendship = Friendship.find_by(user: user, friend: friend)
    expect(friendship.name).to eq 'friend'
    friend.update!(nickname: 'nickname')
    expect(friendship.reload.name).to eq 'nickname'
    friendship.update!(contact_name: 'contact_name')
    expect(friendship.reload.name).to eq 'contact_name'
    friendship.update!(remarked_name: 'remarked_name')
    expect(friendship.reload.name).to eq 'remarked_name'
  end
end

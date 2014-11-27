require 'rails_helper'
require 'timecop'

RSpec.describe Friendship, :type => :model do
  let(:user) { create(:user, username: 'user', mobile: '18668158203', mobile_verified: true) }
  let(:friend) { create(:user, username: 'friend', mobile: '15158166372', mobile_verified: true) }

  it '.create_friendships' do
    user.contacts.create!(name: 'friend_contact_name', number: '15158166372')
    friend.contacts.create!(name: 'user_contact_name', number: '18668158203')
    expect(Friendship.create_friendships(user, friend)).to eq true
    expect(user.friends).to include friend
    expect(friend.friends).to include user
    expect(Friendship.find_by(user: user, friend: friend).contact_name).to eq 'friend_contact_name'
    expect(Friendship.find_by(user: friend, friend: user).contact_name).to eq 'user_contact_name'
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

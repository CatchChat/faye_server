require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:user) { create(:user, username: 'user', mobile: '18668158203', mobile_verified: true) }
  let(:friend) { create(:user, username: 'friend', mobile: '15158166372', mobile_verified: true) }

  describe '#name_by_friend' do
    it 'is friend' do
      Friendship.create_friendships(user, friend)
      user.friendships.find_by(friend: friend).update!(remarked_name: 'remarked_name1')
      friend.friendships.find_by(friend: user).update!(remarked_name: 'remarked_name2')
      expect(user.name_by_friend(friend)).to eq 'remarked_name1'
      expect(friend.name_by_friend(user)).to eq 'remarked_name2'
    end

    it 'is not friend and is contacts friend' do
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
      user.contacts.create!(name: 'friend_contact_name', number: friend.mobile)
      friend.contacts.create!(name: 'user_contact_name', number: user.mobile)
      expect(user.name_by_friend(friend)).to eq 'user_contact_name'
      expect(friend.name_by_friend(user)).to eq 'friend_contact_name'
    end

    it 'is not friend and is not contacts friend' do
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
      expect(user.name_by_friend(friend)).to eq user.name
      expect(friend.name_by_friend(user)).to eq friend.name
    end
  end
end

require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:user) { create(:user, username: 'user') }
  let(:friend) { create(:user, username: 'friend') }

  describe '#name_by_friend' do
    it 'is friend' do
      Friendship.create_friendships(user, friend)
      user.friendships.find_by(friend: friend).update!(remarked_name: 'remarked_name1')
      friend.friendships.find_by(friend: user).update!(remarked_name: 'remarked_name2')
      expect(user.name_by_friend(friend)).to eq 'remarked_name1'
      expect(friend.name_by_friend(user)).to eq 'remarked_name2'
    end

    it 'is not friend' do
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
      expect(user.name_by_friend(friend)).to eq user.name
      expect(friend.name_by_friend(user)).to eq friend.name
    end
  end
end

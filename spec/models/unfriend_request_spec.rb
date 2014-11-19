require 'rails_helper'

RSpec.describe UnfriendRequest, :type => :model do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  it 'Should unfriend when create' do
    Friendship.create_friendships(user.id, friend.id)
    expect(user.friends).to include friend
    expect(friend.friends).to include user
    user.unfriend_requests.create!(friend_id: friend.id)
    expect(user.friends.reload).to_not include friend
    expect(friend.friends.reload).to_not include user
  end
end

require 'rails_helper'

RSpec.describe UnfriendRequest, :type => :model do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  it 'Should remove friend when create' do
    user.friends << friend
    expect(user.friends).to include friend
    expect(user.friends_count).to eq 1
    user.unfriend_requests.create!(friend_id: friend.id)
    expect(user.friends.reload).to_not include friend
    expect(user.friends_count).to eq 0
  end
end

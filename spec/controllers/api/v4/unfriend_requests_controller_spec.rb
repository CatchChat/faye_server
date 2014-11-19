require 'rails_helper'

RSpec.describe Api::V4::UnfriendRequestsController, :type => :controller do

  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'POST create' do

    it 'should return :not_found when friend is not found' do
      post :create, friend_id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'should return :not_found when he is not friend' do
      expect(user.friends).to_not include friend
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_not_found
    end

    it 'should unfriend when success' do
      Friendship.create_friendships(user, friend)
      expect(user.friends).to include friend
      expect(friend.friends).to include user
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_success
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
    end
  end
end

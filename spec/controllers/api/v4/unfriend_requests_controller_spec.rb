require 'rails_helper'

RSpec.describe Api::V4::UnfriendRequestsController, :type => :controller do

  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'POST create' do

    it 'When friend is not found' do
      post :create, friend_id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'When is not friend relationship' do
      expect(user.friends).to_not include friend
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_not_found
    end

    it 'When success should remove friend' do
      user.friends << friend
      expect(user.friends).to include friend
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_success
      expect(user.friends.reload).to_not include friend
    end
  end
end

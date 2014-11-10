require 'rails_helper'

RSpec.describe Api::V4::FriendshipsGroupsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'GET index' do

    it 'group is not found' do
      get :index, group_id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'success' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      get :index, group_id: group.id, format: :json
      expect(response).to be_success
      expect(response).to render_template(:index)
    end
  end

  describe 'POST create' do

    it 'group is not found' do
      post :create, group_id: 0, friend_id: friend.id, format: :json
      expect(response).to be_not_found
    end

    it 'not friend' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      expect(current_user.friends).to_not include friend
      post :create, group_id: group.id, friend_id: friend.id, format: :json
      expect(response).to be_not_found
    end

    it 'success' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      friend_request = current_user.friend_requests.create!(friend_id: friend.id)
      friend_request.accept
      expect(current_user.friends).to include friend
      post :create, group_id: group.id, friend_id: friend.id, format: :json
      expect(response).to be_success
      expect(response).to render_template(:create)
    end
  end

  describe 'DELETE destroy' do

    it 'group is not found' do
      delete :destroy, group_id: 0, id: friend.id, format: :json
      expect(response).to be_not_found
    end

    it 'friend is not in group' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      friend_request = current_user.friend_requests.create!(friend_id: friend.id)
      friend_request.accept
      expect(current_user.friends).to include friend
      expect(group.friends).to_not include friend
      delete :destroy, group_id: group.id, id: friend.id, format: :json
      expect(response).to be_not_found
    end

    it 'success' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      friend_request = current_user.friend_requests.create!(friend_id: friend.id)
      friend_request.accept
      expect(current_user.friends).to include friend
      group.friendships << current_user.friendships.find_by(friend_id: friend.id)
      expect(group.friends).to include friend
      delete :destroy, group_id: group.id, id: friend.id, format: :json
      expect(response).to be_success
    end
  end
end

require 'rails_helper'

RSpec.describe Api::V4::FriendshipsGroupsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'POST create' do

    it 'group is not found' do
      post :create, group_id: 0, friendship_id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'not friend' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      post :create, group_id: group.id, friendship_id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'success' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      friendship = current_user.friendships.create!(friend_id: friend.id)
      expect(current_user.friends).to include friend
      expect(group.friends).to_not include friend
      post :create, group_id: group.id, friendship_id: friendship.id, format: :json
      expect(group.reload.friends).to include friend
      expect(response).to be_success
    end
  end

  describe 'DELETE destroy' do

    it 'group is not found' do
      delete :destroy, group_id: 0, friendship_id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'friend is not in group' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      friendship = current_user.friendships.create!(friend_id: friend.id)
      expect(current_user.friends).to include friend
      expect(group.friends).to_not include friend
      delete :destroy, group_id: group.id, friendship_id: friendship.id, format: :json
      expect(response).to be_not_found
    end

    it 'success' do
      expect(current_user.groups).to be_present
      group = current_user.groups.first
      friendship = current_user.friendships.create!(friend_id: friend.id)
      expect(current_user.friends).to include friend
      group.friendships << friendship
      expect(group.friends).to include friend
      delete :destroy, group_id: group.id, friendship_id: friendship.id, format: :json
      expect(group.reload.friends).to_not include friend
      expect(response).to be_success
    end
  end
end

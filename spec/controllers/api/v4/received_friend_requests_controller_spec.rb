require 'rails_helper'

RSpec.describe Api::V4::ReceivedFriendRequestsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in friend
  end

  describe 'PATCH accept' do

    it 'When friend request is not found' do
      patch :accept, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When accept failed' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      friend_request.reject!
      patch :accept, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(response.body).to eq({ error: subject.t('.accept_error') }.to_json)
    end

    it 'should add friend when accepted' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      expect(friend_request).to_not be_accepted
      patch :accept, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_accepted
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(user.friends).to include friend
    end
  end

  describe 'PATCH reject' do

    it 'When friend request is not found' do
      patch :reject, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When reject failed' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      friend_request.accept!
      patch :reject, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(response.body).to eq({ error: subject.t('.reject_error') }.to_json)
    end

    it 'should not add friend when rejected ' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      expect(friend_request).to_not be_rejected
      patch :reject, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_rejected
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(user.friends).to_not include friend
    end
  end

  describe 'PATCH block' do

    it 'When friend request is not found' do
      patch :block, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When block failed' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      friend_request.accept!
      patch :block, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(response.body).to eq({ error: subject.t('.block_error') }.to_json)
    end

    it 'should not add friend when blocked' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      expect(friend_request).to_not be_blocked
      patch :block, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_blocked
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(user.friends).to_not include friend
    end
  end
end

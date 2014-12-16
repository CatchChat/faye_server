require 'rails_helper'

RSpec.describe Api::V4::ReceivedFriendRequestsController, :type => :controller, sidekiq: :inline do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in friend
  end

  describe 'GET index' do

    describe 'support page and per_page' do

      it "default page is 1, default per_page is #{Kaminari.config.default_per_page}" do
        get :index, format: :json
        expect(response).to be_success
        expect(response).to render_template(:index)
        expect(json_response['current_page']).to eq 1
        expect(json_response['per_page']).to eq Kaminari.config.default_per_page
      end

      it 'should return the correct current_page and per_page' do
        get :index, format: :json, page: 10, per_page: 5
        expect(response).to be_success
        expect(response).to render_template(:index)
        expect(json_response['current_page']).to eq 10
        expect(json_response['per_page']).to eq 5
      end
    end

    describe 'support sort and direction' do

      before do
        1.upto(10) do |index|
          user = FactoryGirl.create(:user, username: "test#{index}")
          friend.received_friend_requests.create(user_id: user.id)
        end
      end

      it 'default sort is id, default direction is DESC' do
        get :index, format: :json
        expect(response).to be_success
        expect(response).to render_template(:index)
        ids = json_response['friend_requests'].map { |request| request['id'] }
        expect(ids.length).to eq 10
        expect(ids).to eq(ids.sort { |x, y| y <=> x })
      end

      it 'should return the correct order' do
        get :index, format: :json, sort: :created_at, direction: 'ASC'
        expect(response).to be_success
        expect(response).to render_template(:index)
        created_ats = json_response['friend_requests'].map { |request| request['created_at'] }
        expect(created_ats.length).to eq 10
        expect(created_ats).to eq(created_ats.sort)
      end
    end

    describe 'support state' do

      before do
        8.times do |index|
          user = FactoryGirl.create(:user, username: "test#{index}")
          friend.received_friend_requests.create(user_id: user.id, state: (index % 4) + 1)
        end
      end

      it 'should return the correct count' do
        FriendRequest::STATES.keys.each do |state|
          get :index, format: :json, state: state
          expect(response).to be_success
          expect(response).to render_template(:index)
          expect(json_response['count']).to eq 2
        end
      end
    end
  end

  describe 'PATCH accept' do

    it 'should return :not_found when friend request is not found' do
      patch :accept, id: 0, format: :json
      expect(response).to be_not_found
      expect(json_response).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'failed' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      friend_request.reject!
      patch :accept, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(json_response).to eq({ 'error' => subject.t('.accept_error') })
    end

    it 'should create friendships when accepted' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      expect(friend_request).to_not be_accepted
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
      expect(Pusher).to receive(:push_to_user).with(
        user.id,
        'content' => subject.t('notification.accepted_friend_request', friend_name: friend.name_by_friend(user))
      )
      patch :accept, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_accepted
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(user.friends.reload).to include friend
      expect(friend.friends.reload).to include user
    end
  end

  describe 'PATCH reject' do

    it 'should return :not_found when friend request is not found' do
      patch :reject, id: 0, format: :json
      expect(response).to be_not_found
      expect(json_response).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'failed' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      friend_request.accept!
      patch :reject, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(json_response).to eq({ 'error' => subject.t('.reject_error') })
    end

    it 'should not create friendships when rejected ' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      expect(friend_request).to_not be_rejected
      expect(Pusher).to receive(:push_to_user).with(
        user.id,
        'content' => subject.t('notification.rejected_friend_request', friend_name: friend.name_by_friend(user))
      )
      patch :reject, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_rejected
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
    end
  end

  describe 'PATCH block' do

    it 'should return :not_found when friend request is not found' do
      patch :block, id: 0, format: :json
      expect(response).to be_not_found
      expect(json_response).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'block failed' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      friend_request.accept!
      patch :block, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(json_response).to eq({ 'error' => subject.t('.block_error') })
    end

    it 'should not create friendships when blocked' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      expect(friend_request).to_not be_blocked
      expect(Pusher).to receive(:push_to_user).with(
        user.id,
        'content' => subject.t('notification.blocked_friend_request', friend_name: friend.name_by_friend(user))
      )
      patch :block, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_blocked
      expect(response).to be_success
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
    end
  end

  describe 'DELETE destroy' do

    it 'should return :not_found when friend request is not found' do
      delete :destroy, id: 0, format: :json
      expect(response).to be_not_found
      expect(json_response).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'should return :success when success' do
      friend_request = current_user.friend_requests.create!(friend_id: friend.id)
      friend_request.reject!
      delete :destroy, id: friend_request.id, format: :json
      expect(response).to be_success
      expect { friend_request.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

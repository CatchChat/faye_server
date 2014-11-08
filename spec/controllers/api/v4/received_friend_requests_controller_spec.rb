require 'rails_helper'

RSpec.describe Api::V4::ReceivedFriendRequestsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in friend
  end

  describe 'GET index' do

    it 'should be success and render index template' do
      get :index, format: :json
      expect(response).to be_success
      expect(response).to render_template(:index)
    end

    describe 'support page and per_page' do

      it 'default page is 1, default per_page is 10' do
        get :index, format: :json
        body = JSON.parse response.body
        expect(body['current_page']).to eq 1
        expect(body['per_page']).to eq 10
      end

      it 'should return the correct current_page and per_page' do
        get :index, format: :json, page: 10, per_page: 5
        body = JSON.parse response.body
        expect(body['current_page']).to eq 10
        expect(body['per_page']).to eq 5
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
        body = JSON.parse response.body
        ids = body['friend_requests'].map { |request| request['id'] }
        expect(ids.length).to eq 10
        expect(ids).to eq(ids.sort { |x, y| y <=> x })
      end

      it 'should return the correct order' do
        get :index, format: :json, sort: :created_at, direction: 'ASC'
        body = JSON.parse response.body
        created_ats = body['friend_requests'].map { |request| request['created_at'] }
        expect(created_ats.length).to eq 10
        expect(created_ats).to eq(created_ats.sort)
      end
    end
  end

  describe 'PATCH accept' do

    it 'should return :not_found when friend request is not found' do
      patch :accept, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'accept failed' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      friend_request.reject!
      patch :accept, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(response.body).to eq({ error: subject.t('.accept_error') }.to_json)
    end

    it 'should add friend when accepted' do
      friend_request = current_user.received_friend_requests.create!(user_id: user.id)
      expect(friend_request).to_not be_accepted
      patch :accept, id: friend_request.id, contact_name: 'contact_name', format: :json
      expect(friend_request.reload).to be_accepted
      friendship = Friendship.find_by(user_id: user.id, friend_id: friend.id)
      expect(friendship.contact_name).to eq 'contact_name'
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(user.friends).to include friend
    end
  end

  describe 'PATCH reject' do

    it 'should return :not_found when friend request is not found' do
      patch :reject, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'reject failed' do
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

    it 'should return :not_found when friend request is not found' do
      patch :block, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'block failed' do
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
      expect(user.friends).to_not include friend
    end
  end

  describe 'DELETE destroy' do

    it 'should return :not_found when friend request is not found' do
      delete :destroy, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'should return :success when success' do
      friend_request = current_user.friend_requests.create!(friend_id: friend.id)
      delete :destroy, id: friend_request.id, format: :json
      expect(response).to be_success
      expect { friend_request.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

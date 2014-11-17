require 'rails_helper'

RSpec.describe Api::V4::SentFriendRequestsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
    AccessToken.current = user.access_tokens.first
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
          friend = FactoryGirl.create(:user, username: "test#{index}")
          user.sent_friend_requests.create(friend_id: friend.id)
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
          friend = FactoryGirl.create(:user, username: "test#{index}")
          user.sent_friend_requests.create(friend_id: friend.id, state: (index % 4) + 1)
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

  describe 'POST create' do

    it 'should return :not_found when friend is not found' do
      post :create, friend_id: 0, format: :json
      expect(response).to be_not_found
      expect(json_response).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'should return :forbidden when already friends' do
      current_user.friends << friend
      expect(current_user.friends).to be_include(friend)
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_forbidden
      expect(json_response).to eq({ 'error' => subject.t('.already_friend', friend_name: friend.name) })
    end

    it 'should return :unprocessable_entity when already request' do
      friend_request = current_user.sent_friend_requests.create!(friend_id: friend.id)
      expect(friend_request).to be_pending
      post :create, friend_id: friend.id
      expect(response).to be_unprocessable
    end

    it 'should return :forbidden when blocked' do
      current_user.sent_friend_requests.create!(
        friend_id: friend.id,
        state: FriendRequest::STATES[:blocked]
      )
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_forbidden
      expect(json_response).to eq({ 'error' => subject.t('.blocked', friend_name: friend.name) })
    end

    it 'should return :success when success' do
      allow(Pusher).to receive(:push_to_user)
      count = current_user.sent_friend_requests.count
      post :create, friend_id: friend.id, format: :json
      expect(current_user.sent_friend_requests.count).to eq(count + 1)
      expect(response).to be_success
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE destroy' do

    it 'should return :not_found when friend is not found' do
      delete :destroy, id: 0, format: :json
      expect(response).to be_not_found
      expect(json_response).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'should return :success when success' do
      friend_request = current_user.sent_friend_requests.create!(friend_id: friend.id)
      delete :destroy, id: friend_request.id, format: :json
      expect(response).to be_success
      expect { friend_request.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

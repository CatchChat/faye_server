require 'rails_helper'

RSpec.describe Api::V4::FriendRequestsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'GET index' do

    it 'should be success and render index template' do
      get :index, format: :json
      expect(response).to be_success
      expect(response).to render_template(:index)
    end

    describe 'support page and per_page' do

      it "default page is 1, default per_page is #{Kaminari.config.default_per_page}" do
        get :index, format: :json
        body = JSON.parse response.body
        expect(body['current_page']).to eq 1
        expect(body['per_page']).to eq Kaminari.config.default_per_page
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
          friend = FactoryGirl.create(:user, username: "test#{index}")
          user.friend_requests.create(friend_id: friend.id)
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

  describe 'POST create' do

    it 'should return :not_found when friend is not found' do
      post :create, friend_id: 0, format: :json
      expect(response).to be_not_found
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'should return :forbidden when already friends' do
      current_user.friends << friend
      expect(current_user.friends).to be_include(friend)
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.already_friend', friend_name: friend.name) })
    end

    it 'should return :unprocessable_entity when already request' do
      friend_request = current_user.friend_requests.create!(friend_id: friend.id)
      expect(friend_request).to be_pending
      post :create, friend_id: friend.id
      expect(response).to be_unprocessable
    end

    it 'should return :forbidden when blocked' do
      current_user.friend_requests.create!(
        friend_id: friend.id,
        state: FriendRequest::STATES[:blocked]
      )
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.blocked', friend_name: friend.name) })
    end

    it 'should return :success when success' do
      post :create, friend_id: friend.id, format: :json
      expect(response).to be_success
      friend_request = current_user.friend_requests.last
      expect(friend_request.friend_id).to eq friend.id
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE destroy' do

    it 'should return :not_found when friend is not found' do
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

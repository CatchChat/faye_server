require 'rails_helper'

RSpec.describe Api::V4::FriendRequestsController, :type => :controller do

  let(:current_user) { subject.current_user }

  def format_json(friend_request)
    json = friend_request.attributes.except('created_at', 'updated_at')
    json.merge(
      created_at: friend_request.created_at.strftime(I18n.t('time.formats.iso8601')),
      updated_at: friend_request.updated_at.strftime(I18n.t('time.formats.iso8601')),
      created_at_string: friend_request.created_at.strftime(I18n.t('time.formats.default')),
      updated_at_string: friend_request.updated_at.strftime(I18n.t('time.formats.default')),
      state_string: I18n.t("models.friend_request.state.#{friend_request.human_state_name}"),
      user: {
        id: friend_request.user.id,
        nickname: friend_request.user.nickname,
        username: friend_request.user.username
      },
      friend: {
        id: friend_request.friend.id,
        nickname: friend_request.friend.nickname,
        username: friend_request.friend.username
      }
    )
  end

  before do
    @user   = FactoryGirl.create(:user, username: 'user')
    @friend = FactoryGirl.create(:user, username: 'friend')
    sign_in @user
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
          friend = FactoryGirl.create(:user, username: "test#{index}")
          @user.friend_requests.create(friend_id: friend.id)
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

    it 'When friend is not found' do
      post :create, friend_id: 0, format: :json
      expect(response).to be_not_found
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'When already friends' do
      current_user.friends << @friend
      expect(current_user.friends).to be_include(@friend)
      post :create, friend_id: @friend.id, format: :json
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.already_friend', friend_name: @friend.name) })
    end

    it 'When already request' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      expect(friend_request).to be_pending
      post :create, friend_id: @friend.id
      expect(response).to be_unprocessable
    end

    it 'When blocked' do
      current_user.friend_requests.create!(
        friend_id: @friend.id,
        state: FriendRequest::STATES[:blocked]
      )
      post :create, friend_id: @friend.id, format: :json
      expect(response).to be_forbidden
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.blocked', friend_name: @friend.name) })
    end

    it 'When success' do
      post :create, friend_id: @friend.id, format: :json
      expect(response).to be_success
      friend_request = current_user.friend_requests.last
      expect(friend_request.friend_id).to eq @friend.id
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH accept' do

    it 'When friend request is not found' do
      patch :accept, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When accept failed' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      friend_request.reject!
      patch :accept, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(response.body).to eq({ error: subject.t('.accept_error') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      expect(friend_request).to_not be_accepted
      patch :accept, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_accepted
      expect(response).to be_success
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH reject' do

    it 'When friend request is not found' do
      patch :reject, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When reject failed' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      friend_request.accept!
      patch :reject, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(response.body).to eq({ error: subject.t('.reject_error') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      expect(friend_request).to_not be_rejected
      patch :reject, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_rejected
      expect(response).to be_success
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH block' do

    it 'When friend request is not found' do
      patch :block, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When block failed' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      friend_request.accept!
      patch :block, id: friend_request.id, format: :json
      expect(response).to be_unprocessable
      expect(response.body).to eq({ error: subject.t('.block_error') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      expect(friend_request).to_not be_blocked
      patch :block, id: friend_request.id, format: :json
      expect(friend_request.reload).to be_blocked
      expect(response).to be_success
      expect(response).to render_template(:show)
    end
  end

  describe 'GET show' do

    it 'When friend request is not found' do
      get :show, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      get :show, id: friend_request.id, format: :json
      expect(response).to be_success
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE destroy' do

    it 'When friend request id not found' do
      delete :destroy, id: 0, format: :json
      expect(response).to be_not_found
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      delete :destroy, id: friend_request.id, format: :json
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect { friend_request.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

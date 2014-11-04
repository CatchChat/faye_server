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
      state_string: I18n.t("models.friend_request.state.#{friend_request.human_state_name}")
    )
  end

  before do
    @user   = FactoryGirl.create(:user, username: 'user')
    @friend = FactoryGirl.create(:user, username: 'friend')
    sign_in @user
  end

  describe 'POST create' do

    it 'When friend is not found' do
      post :create, friend_id: 0
      expect(response.code).to eq '404'
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.not_found') })
    end

    it 'When already friends' do
      current_user.friends << @friend
      expect(current_user.friends).to be_include(@friend)
      post :create, friend_id: @friend.id
      expect(response.code).to eq '403'
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.already_friend', friend_name: @friend.name) })
    end

    it 'When blocked' do
      current_user.friend_requests.create!(
        friend_id: @friend.id,
        state: FriendRequest::STATES[:blocked]
      )
      post :create, friend_id: @friend.id
      expect(response.code).to eq '403'
      expect(JSON.parse(response.body)).to eq({ 'error' => subject.t('.blocked', friend_name: @friend.name) })
    end

    it 'When success' do
      post :create, friend_id: @friend.id
      expect(response.code).to eq '200'
      friend_request = current_user.friend_requests.last
      expect(friend_request.friend_id).to eq @friend.id
      expect(response.body).to eq(format_json(friend_request).to_json)
    end
  end

  describe 'PATCH accept' do

    it 'When friend request is not found' do
      patch :accept, id: 0
      expect(response.code).to eq '404'
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When accept failed' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      friend_request.reject!
      patch :accept, id: friend_request.id
      expect(response.code).to eq '422'
      expect(response.body).to eq({ error: subject.t('.accept_error') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      expect(friend_request).to_not be_accepted
      patch :accept, id: friend_request.id
      expect(friend_request.reload).to be_accepted
      expect(response.code).to eq '200'
      expect(response.body).to eq(format_json(friend_request).to_json)
    end
  end

  describe 'PATCH reject' do

    it 'When friend request is not found' do
      patch :reject, id: 0
      expect(response.code).to eq '404'
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When reject failed' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      friend_request.accept!
      patch :reject, id: friend_request.id
      expect(response.code).to eq '422'
      expect(response.body).to eq({ error: subject.t('.reject_error') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      expect(friend_request).to_not be_rejected
      patch :reject, id: friend_request.id
      expect(friend_request.reload).to be_rejected
      expect(response.code).to eq '200'
      expect(response.body).to eq(format_json(friend_request).to_json)
    end
  end

  describe 'PATCH block' do

    it 'When friend request is not found' do
      patch :block, id: 0
      expect(response.code).to eq '404'
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When block failed' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      friend_request.accept!
      patch :block, id: friend_request.id
      expect(response.code).to eq '422'
      expect(response.body).to eq({ error: subject.t('.block_error') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      expect(friend_request).to_not be_blocked
      patch :block, id: friend_request.id
      expect(friend_request.reload).to be_blocked
      expect(response.code).to eq '200'
      expect(response.body).to eq(format_json(friend_request).to_json)
    end
  end

  describe 'GET show' do

    it 'When friend request is not found' do
      get :show, id: 0
      expect(response.code).to eq '404'
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      get :show, id: friend_request.id
      expect(response.code).to eq '200'
      expect(response.body).to eq(format_json(friend_request).to_json)
    end
  end

  describe 'DELETE destroy' do

    it 'When friend request id not found' do
      delete :destroy, id: 0
      expect(response.code).to eq '404'
      expect(response.body).to eq({ error: subject.t('.not_found') }.to_json)
    end

    it 'When success' do
      friend_request = current_user.friend_requests.create!(friend_id: @friend.id)
      delete :destroy, id: friend_request.id
      expect(response.code).to eq '200'
      expect(response.body).to eq(format_json(friend_request).to_json)
      expect { friend_request.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

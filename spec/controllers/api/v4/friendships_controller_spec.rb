require 'rails_helper'

RSpec.describe Api::V4::FriendshipsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }
  let(:friendship) {
    user.friendships.create!(friend: friend, remarked_name: 'remarked_name', contact_name: 'contact_name')
  }

  before do
    sign_in user
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

    it 'should return the correct count' do
      10.times do |index|
        user.friends << create(:user, username: "friend#{index}")
      end

      expect(user.friends.count).to eq(10)
      get :index, format: :json
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 10
      expect(json_response[:friendships].size).to eq 10
    end
  end

  describe 'GET recent' do

    before do
      10.times do |index|
        _friend = create(:user, username: "friend#{index}")
        user.friends << _friend
        Message.create!(sender: user, recipient: _friend, media_type: Message.media_types[:text]) if index % 3 == 0
        Message.create!(sender: _friend, recipient: user, media_type: Message.media_types[:text]) if index % 3 == 1
      end
    end

    it 'should return the correct count' do
      get :recent, format: :json
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 7
      expect(json_response[:friendships].size).to eq 7
    end
  end

  describe 'GET search' do

    before do
      10.times do |index|
        _friend = create(:user, username: "username#{index}", nickname: "nickname#{index}")
        user.friendships.create!(friend: _friend, remarked_name: "remarked_name#{index}", contact_name: "contact_name#{index}")
      end
    end

    it 'q is username' do
      get :search, format: :json, q: 'username'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 10
      expect(json_response[:friendships].size).to eq 10

      get :search, format: :json, q: 'username1'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 1
      expect(json_response[:friendships].size).to eq 1
    end

    it 'q is nickname' do
      get :search, format: :json, q: 'nickname'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 10
      expect(json_response[:friendships].size).to eq 10

      get :search, format: :json, q: 'nickname1'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 1
      expect(json_response[:friendships].size).to eq 1
    end

    it 'q is remarked_name' do
      get :search, format: :json, q: 'nickname'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 10
      expect(json_response[:friendships].size).to eq 10

      get :search, format: :json, q: 'nickname1'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 1
      expect(json_response[:friendships].size).to eq 1
    end

    it 'q is contact_name' do
      get :search, format: :json, q: 'contact_name'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 10
      expect(json_response[:friendships].size).to eq 10

      get :search, format: :json, q: 'contact_name1'
      expect(response).to be_success
      expect(response).to render_template(:index)
      expect(json_response[:count]).to eq 1
      expect(json_response[:friendships].size).to eq 1
    end
  end

  describe 'GET show' do

    it 'friendship is not found' do
      get :show, format: :json, id: 0
      expect(response).to be_not_found
      expect(json_response[:error]).to eq subject.t('.not_found')
    end

    it 'success' do
      get :show, format: :json, id: friendship.id
      expect(response).to be_success
      expect(response).to render_template(:show)
      expect(json_response[:name]).to eq friendship.name
      expect(json_response[:remarked_name]).to eq 'remarked_name'
      expect(json_response[:contact_name]).to eq 'contact_name'
    end
  end

  describe 'PUT update' do

    it 'friendship is not found' do
      put :update, format: :json, id: 0, remarked_name: 'new_remarked_name', contact_name: 'new_contact_name'
      expect(response).to be_not_found
      expect(json_response[:error]).to eq subject.t('.not_found')
    end

    it 'success' do
      put :update, format: :json, id: friendship.id, remarked_name: 'new_remarked_name', contact_name: 'new_contact_name'
      expect(response).to be_success
      expect(response).to render_template(:update)
      expect(json_response[:name]).to eq 'new_remarked_name'
      expect(json_response[:remarked_name]).to eq 'new_remarked_name'
      expect(json_response[:contact_name]).to eq 'new_contact_name'
    end
  end

  describe 'PATCH move_to_top' do

    it 'friendship is not found' do
      patch :move_to_top, format: :json, id: 0
      expect(response).to be_not_found
      expect(json_response[:error]).to eq subject.t('.not_found')
    end

    it 'success' do
      10.times do |index|
        _friend = create(:user, username: "username#{index}", nickname: "nickname#{index}")
        user.friendships.create!(friend: _friend, remarked_name: "remarked_name#{index}", contact_name: "contact_name#{index}")
      end

      _friendship = user.friendships.last
      expect(_friendship).to be_last
      patch :move_to_top, format: :json, id: _friendship.id
      expect(response).to be_success
      expect(_friendship.reload).to be_first
    end
  end
end

require 'rails_helper'

RSpec.describe Api::V4::ContactsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'POST upload' do

    it 'params error' do
      post :upload, format: :json, contacts: nil
      expect(response).to be_unprocessable
      expect(json_response[:error]).to eq subject.t('.contacts_error')
    end

    it 'overwrite the old contacts' do
      user.contacts.create!(name: 'xxx', number: '15158166372')
      post :upload, format: :json, contacts: [{ name: 'tumayun', number: '15158166372' }].to_json
      expect(response).to be_success
      expect(json_response[:registered_contacts]).to eq []
    end

    it 'no registered contacts' do
      post :upload, format: :json, contacts: [{ name: 'tumayun', number: '15158166372' }].to_json
      expect(response).to be_success
      expect(json_response[:registered_contacts]).to eq []

      Friendship.create_friendships(user, friend)
      user.update!(mobile: '15158166723')
      friend.update!(mobile: '15158166372')
      post :upload, format: :json, contacts: [{ name: 'tumayun', number: '15158166372' }].to_json
      expect(response).to be_success
      expect(json_response[:registered_contacts]).to eq []
    end

    it 'return registered contacts' do
      Friendship.create_friendships(user, friend)
      user.update!(mobile: '15158166723', mobile_verified: true, phone_code: '86')
      friend.update!(mobile: '15158166372', mobile_verified: true, phone_code: '86', avatar_url: 'http://a.b.c/d.png', nickname: 'mynick')
      post :upload, format: :json, contacts: [{ name: 'tumayun', number: '15158166372' }].to_json
      expect(response).to be_success
      expect(json_response[:registered_contacts]).to eq [{ 'name' => 'tumayun', 'user' => {'id' => friend.id, 'username' => friend.username, 'avatar_url' => friend.avatar_url, 'nickname' => friend.nickname, 'normalized_mobile' => friend.normalized_mobile }}]
    end
  end
end

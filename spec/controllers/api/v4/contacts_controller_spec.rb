require 'rails_helper'

RSpec.describe Api::V4::ContactsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user, username: 'user') }

  before do
    sign_in user
  end

  describe 'POST upload' do

    it 'params error' do
      post :upload, format: :json, contacts: nil
      expect(response).to be_unprocessable
      expect(json_response[:error]).to eq subject.t('.contacts_error')
    end

    it 'validation fails' do
      post :upload, format: :json, contacts: [{ name: '', number: '' }].to_json
      expect(response).to be_unprocessable
      expect(json_response[:error]).to eq subject.t('.contacts_error')

      user.contacts.create!(name: 'xxx', number: '15158166372')
      post :upload, format: :json, contacts: [{ name: 'tumayun', number: '15158166372' }].to_json
      expect(response).to be_unprocessable
      expect(json_response[:error]).to eq subject.t('.contacts_error')
    end

    it 'success' do
      post :upload, format: :json, contacts: [{ name: 'tumayun', number: '15158166372' }].to_json
      expect(response).to be_success
    end
  end
end

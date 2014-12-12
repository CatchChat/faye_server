require 'rails_helper'

RSpec.describe Api::V4::UsersController, :type => :controller do

  let(:user) { FactoryGirl.create(:user, username: 'user') }

  before do
    sign_in user
  end

  describe 'GET search' do

    it 'q is blank' do
      get :search, format: :json, q: ''
      expect(assigns(:users)).to be_empty
    end

    it 'q is not blank' do
      get :search, format: :json, q: 'use'
      expect(assigns(:users)).to be_empty

      get :search, format: :json, q: 'user'
      expect(assigns(:users)).to include user
    end
  end

  describe 'GET username_validate' do
    before do
      sign_out user
    end

    it 'username is invalid' do
      get :username_validate, format: :json, username: 'qwe'
      expect(json_response).to eq({ 'available' => false, 'message' => subject.t('.username_invalid') })

      get :username_validate, format: :json, username: 'qweqwe123qweqweqw'
      expect(json_response).to eq({ 'available' => false, 'message' => subject.t('.username_invalid') })

      get :username_validate, format: :json, username: 'user.name'
      expect(json_response).to eq({ 'available' => false, 'message' => subject.t('.username_invalid') })
    end

    it 'username has been used' do
      get :username_validate, format: :json, username: user.username
      expect(json_response).to eq({ 'available' => false, 'message' => subject.t('.has_been_used') })
    end

    it 'available' do
      get :username_validate, format: :json, username: 'Tumayun123'
      expect(json_response).to eq({ 'available' => true })
    end
  end

  describe 'GET username_validate' do
    before do
      sign_out user
    end

    it 'phone_code is invalid' do
      get :mobile_validate, {
        format: :json,
        phone_code: '12345',
        mobile: '15158166372'
      }
      expect(response).to be_success
      expect(json_response[:available]).to eq false
      expect(json_response[:message]).to eq subject.t('.phone_code_invalid')
    end

    it 'mobile is invalid' do
      get :mobile_validate, {
        format: :json,
        phone_code: '86',
        mobile: '15158166372111'
      }

      expect(response).to be_success
      expect(json_response[:available]).to eq false
      expect(json_response[:message]).to eq subject.t('.mobile_invalid')
    end

    it 'mobile has been used' do
      create(:user, username: 'test', phone_code: '86', mobile: '15158166372')

      get :mobile_validate, {
        format: :json,
        phone_code: '86',
        mobile: '15158166372'
      }
      expect(response).to be_success
      expect(json_response[:available]).to eq false
      expect(json_response[:message]).to eq subject.t('.has_been_used')
    end

    it 'available' do
      get :mobile_validate, {
        format: :json,
        phone_code: '86',
        mobile: '15158166372'
      }
      expect(response).to be_success
      expect(json_response[:available]).to eq true
    end
  end
end

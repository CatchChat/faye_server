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
end

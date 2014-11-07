require 'rails_helper'

RSpec.describe Api::V4::FriendshipsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'GET index' do

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
  end
end

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
  end
end

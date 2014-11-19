require 'rails_helper'

describe AttachmentsController do
  render_views
  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "qiniu" do
    it 'check param' do
      post :upload_token, provider: 'qiniu', bucket: 'abc', :format => 'json'
      expect(response.status).to eq 406
      expect(json_response[:status]).to eq "error"
      expect(json_response[:message]).to eq "missing params for upload token"
    end

    it 'check param' do
      post :upload_token, provider: 'qiniu', key: 'abc', :format => 'json'
      expect(response.status).to eq 406
      expect(json_response[:status]).to eq "error"
      expect(json_response[:message]).to eq "missing params for upload token"
    end

    it 'returns upload tokens' do
      post :upload_token, provider: 'qiniu', bucket: 'mybucket', key: 'mykey', :format => 'json'
      expect(response.status).to eq 200
      expect(json_response[:token].length).to be > 10
      expect(json_response[:provider]).to eq "qiniu"
      expect(json_response[:key]).to eq "mykey"
      expect(json_response[:bucket]).to eq "mybucket"
    end
  end

  context "upyun" do

    it 'check param' do
      post :upload_token, provider: 'upyun', bucket: 'abc', :format => 'json'
      expect(response.status).to eq 406
      expect(json_response[:status]).to eq "error"
      expect(json_response[:message]).to eq "missing params for upload token"
    end
    it 'returns upload tokens' do
      post :upload_token, provider: 'upyun', bucket: 'mybucket', file_path: '/mykey', file_length: 23, :format => 'json'
      expect(response.status).to eq 200
      expect(json_response[:provider]).to eq "upyun"
      expect(json_response[:token].length).to be > 10
      expect(json_response[:bucket]).to eq "mybucket"
      expect(json_response[:file_path]).to eq "/mykey"
    end
  end
end
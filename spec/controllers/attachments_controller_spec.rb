require 'rails_helper'
require 'services_helper'

describe AttachmentsController do
  render_views
  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  before do
    sign_in user
  end

  context "qiniu" do
    it 'check param' do
      post :upload_token, provider: 'qiniu', bucket: 'abc', :format => 'json'
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
      skip "only upload to qiniu"
      post :upload_token, provider: 'upyun', bucket: 'abc', :format => 'json'
      expect(response.status).to eq 406
      expect(json_response[:status]).to eq "error"
      expect(json_response[:message]).to eq "missing params for upload token"
    end
    it 'returns upload tokens' do
      skip "only upload to qiniu"
      post :upload_token, provider: 'upyun', bucket: 'mybucket', file_path: '/mykey', file_length: 23, :format => 'json'
      expect(response.status).to eq 200
      expect(json_response[:provider]).to eq "upyun"
      expect(json_response[:token].length).to be > 10
      expect(json_response[:bucket]).to eq "mybucket"
      expect(json_response[:file_path]).to eq "/mykey"
    end
  end

  context "s3" do
    it 'check param' do
      skip "only upload from server"
      post :upload_fields, provider: 's3', bucket: 'abc', :format => 'json'
      expect(response.status).to eq 406
      expect(json_response[:status]).to eq "error"
      expect(json_response[:message]).to eq "missing params for upload fields"
    end

    it 'returns upload fields' do
      skip "only upload from server"
      post :upload_fields, provider: 's3', bucket: 'mybucket', key: 'mykey', :format => 'json'
      expect(response.status).to eq 200
      expect(json_response[:status]).to eq "ok"
      #puts response.body
    end
  end
end

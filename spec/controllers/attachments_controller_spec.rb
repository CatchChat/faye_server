require 'rails_helper'
require 'services_helper'

describe AttachmentsController, sidekiq: :inline do
  render_views
  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  before do
    sign_in user
  end

  context "s3" do
    it 'returns upload form fields' do
      get :s3_upload_form_fields, :id=> user.messages.first.id, :format => 'json'
      expect(response.status).to eq 200
      expect(json_response[:provider]).to eq "s3"
      expect(json_response[:options][:key].length).to be > 10
      expect(json_response[:options][:bucket]).to eq ENV['AWS_BUCKET']
      expect(json_response[:options][:policy][:conditions].length).to eq 6
      expect(json_response[:options][:encoded_policy].length).to be > 10
      expect(json_response[:options][:signature].length).to be > 10
    end
  end

  context "qiniu" do
    it 'check param' do
      get :upload_token, :id => 'not exist', :format => 'json'
      expect(response.status).to eq 406
      expect(json_response[:error]).to eq "missing params for upload token"
    end


    it 'returns upload tokens' do
      get :upload_token, :id=> user.messages.first.id, :format => 'json'
      expect(response.status).to eq 200
      expect(json_response[:provider]).to eq "qiniu"
      expect(json_response[:options][:token].length).to be > 10
      expect(json_response[:options][:key].length).to be > 10
      expect(json_response[:options][:bucket]).to eq ENV['qiniu_attachment_bucket']
    end

    it 'returns public upload tokens' do
      get :public_upload_token, :format => 'json'
      expect(response.status).to eq 200
      expect(json_response[:provider]).to eq "qiniu"
      expect(json_response[:options][:token].length).to be > 10
      expect(json_response[:options][:key].length).to be > 10
      expect(json_response[:options][:bucket]).to eq ENV['qiniu_attachment_public_bucket']
      expect(json_response[:options][:download_url]).to include ENV['qiniu_attachment_public_bucket']
      expect(json_response[:options][:callback_url]).to eq ENV['qiniu_public_callback_url']
    end

    it 'save attachment and push when callback' do

      expect_any_instance_of(Message).to receive(:mark_as_unread)
      expect_any_instance_of(Message).to receive(:push_notification)
      expect(TransferAttachmentsJob).to receive(:perform_async)
      post :callback, provider: 'qiniu',
        bucket: ENV['qiniu_attachment_bucket'], message_id: user.messages.first.id, key: 'test-key', format: 'json'
      expect(response.status).to eq 200
      expect(json_response[:attachment_id]).to be_a(Numeric)

    end

    it 'save public attachment when callback' do
      expect(TransferAttachmentsJob).to receive(:perform_async)
      post :public_callback, provider: 'qiniu',
        bucket: ENV['qiniu_attachment_public_bucket'], key: 'test-key', format: 'json'

      expect(response.status).to eq 200
      expect(json_response[:attachment_id]).to be_a(Numeric)
    end
  end
end

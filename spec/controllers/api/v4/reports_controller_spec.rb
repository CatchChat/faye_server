require 'rails_helper'

RSpec.describe Api::V4::ReportsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  context 'POST create' do
    let(:message) {
      message = friend.messages.create!(
        recipient: user,
        text_content: 'This is a test!',
        attachments: [create(:attachment)]
      )
      message.mark_as_unread!
      message
    }

    it 'message is not found' do
      post :create, format: :json, message_id: 0
      expect(response).to be_not_found
      expect(json_response[:error]).to eq subject.t('.message_not_found')
    end

    it 'create success' do
      post :create, format: :json, message_id: message.id
      expect(response).to be_success
      report = user.reports.find_by(message_id: message.id)
      expect(report.message.attachments).to be_all(&:reserved?)
    end

    it 'create error' do
      user.report_message(message)
      post :create, format: :json, message_id: message.id
      expect(response).to be_unprocessable
    end
  end
end

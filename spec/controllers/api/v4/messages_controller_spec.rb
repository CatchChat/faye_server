require 'rails_helper'

RSpec.describe Api::V4::MessagesController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  describe 'GET unread' do
    before do
      friend.friends << user
      10.times do |index|
        message = friend.sent_messages.create!(recipient: user, text_content: 'This is a test!')
        message.mark_as_unread!
      end

      10.times do |index|
        message = friend.sent_messages.create!(recipient: user, text_content: 'This is a test!')
        message.mark_as_unread!
        message.individual_recipients.each { |individual_recipient|
          individual_recipient.deliver!; individual_recipient.mark_as_read!
        }
      end
    end

    it 'should return the correct number of messages' do
      expect(user.unread_messages.count).to eq 10
      get :unread, format: :json
      expect(response).to be_success
      expect(response).to render_template(:unread)
      expect(json_response[:count]).to eq 10
      expect(json_response[:messages].size).to eq 10

      user.received_messages.each do |message|
        message.individual_recipients.unread.each do |individual_recipient|
          individual_recipient.deliver! if individual_recipient.can_deliver?
          individual_recipient.mark_as_read!
        end
      end

      expect(user.unread_messages.count).to eq 0
      get :unread, format: :json
      expect(response).to be_success
      expect(response).to render_template(:unread)
      expect(json_response[:count]).to eq 0
      expect(json_response[:messages].size).to eq 0
    end
  end

  describe 'POST create' do

    context 'individual message' do

      it 'not found recipient' do
        expect(user.friends).to_not include friend
        post :create, format: :json, recipient_id: friend.id, recipient_type: friend.class.name, text_content: 'This is a test!'
        expect(response).to be_not_found
        expect(json_response).to eq({ 'error' => subject.t('.not_found_recipient') })
      end

      context 'success' do
        before do
          user.friends << friend
        end

        it 'text message' do
          expect(user.friends).to include friend
          expect_any_instance_of(Message).to receive(:push_notification)
          post :create, format: :json, recipient_id: friend.id, recipient_type: friend.class.name, text_content: 'This is a test!'
          expect(response).to be_success
          message = friend.received_messages.last
          expect(message).to be_text
          expect(message).to be_unread
        end

        it 'photo message' do
          expect(user.friends).to include friend
          post :create, format: :json, recipient_id: friend.id, recipient_type: friend.class.name, text_content: 'This is a test!', media_type: Message.media_types[:photo]
          expect(response).to be_success
          message = user.sent_messages.last
          expect(message).to be_photo
          expect(message).to be_draft
        end

        it 'video message' do
          expect(user.friends).to include friend
          post :create, format: :json, recipient_id: friend.id, recipient_type: friend.class.name, text_content: 'This is a test!', media_type: Message.media_types[:video]
          expect(response).to be_success
          message = user.sent_messages.last
          expect(message).to be_video
          expect(message).to be_draft
        end
      end
    end

    context 'group message' do
      before do
        user.friends << friend
      end

      it 'not found recipient' do
        group = friend.groups.create!(name: 'test')
        expect(user.groups).to_not include group
        post :create, format: :json, recipient_id: group.id, recipient_type: group.class.name, text_content: 'This is a test!'
        expect(response).to be_not_found
        expect(json_response).to eq({ 'error' => subject.t('.not_found_recipient') })
      end

      context 'success' do
        before do
          @group = user.groups.last
          @group.friendships << user.friendships.find_by(friend_id: friend.id)
        end

        it 'text message' do
          expect(@group.friends).to include friend
          expect_any_instance_of(Message).to receive(:push_notification)
          post :create, format: :json, recipient_id: @group.id, recipient_type: @group.class.name, text_content: 'This is a test!'
          expect(response).to be_success
          message = friend.received_messages.last
          expect(message).to be_text
          expect(message).to be_unread
        end

        it 'photo message' do
          expect(@group.friends).to include friend
          post :create, format: :json, recipient_id: friend.id, recipient_type: friend.class.name, text_content: 'This is a test!', media_type: Message.media_types[:photo]
          expect(response).to be_success
          message = user.sent_messages.last
          expect(message).to be_photo
          expect(message).to be_draft
        end

        it 'video message' do
          expect(@group.friends).to include friend
          post :create, format: :json, recipient_id: @group.id, recipient_type: @group.class.name, text_content: 'This is a test!', media_type: Message.media_types[:video]
          expect(response).to be_success
          message = user.sent_messages.last
          expect(message).to be_video
          expect(message).to be_draft
        end
      end
    end
  end

  describe 'PATCH mark_as_read' do

    shared_examples 'mark_as_read examples' do
      it 'draft state' do
        expect(@message).to be_draft
        patch :mark_as_read, format: :json, id: @message.id
        expect(response).to be_not_found
        expect(json_response).to eq({ 'error' => subject.t('.not_found') })
      end

      it 'sent state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        patch :mark_as_read, format: :json, id: @message.id
        expect(response).to be_success
        expect(individual_recipient.reload).to be_read
      end

      it 'delivered state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        individual_recipient.deliver!
        patch :mark_as_read, format: :json, id: @message.id
        expect(response).to be_success
        expect(individual_recipient.reload).to be_read
      end

      it 'read state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        individual_recipient.deliver!
        individual_recipient.mark_as_read!
        patch :mark_as_read, format: :json, id: @message.id
        expect(response).to be_success
        expect(individual_recipient.reload).to be_read
      end
    end

    context 'individual message' do
      before do
        friend.friends << user
        @message = friend.sent_messages.create!(recipient: user, text_content: 'This is a test!')
      end

      it_behaves_like 'mark_as_read examples'
    end

    context 'group message' do
      before do
        friend.friends << user
        group = friend.groups.last
        group.friendships << friend.friendships.find_by(friend_id: user.id)
        @message = friend.sent_messages.create!(recipient: group, text_content: 'This is a test!')
      end

      it_behaves_like 'mark_as_read examples'
    end
  end

  describe 'PATCH deliver' do

    shared_examples 'deliver examples' do
      it 'draft state' do
        expect(@message).to be_draft
        patch :deliver, format: :json, id: @message.id
        expect(response).to be_not_found
        expect(json_response).to eq({ 'error' => subject.t('.not_found') })
      end

      it 'sent state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        patch :deliver, format: :json, id: @message.id
        expect(response).to be_success
        expect(individual_recipient.reload).to be_delivered
      end

      it 'delivered state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        individual_recipient.deliver!
        patch :deliver, format: :json, id: @message.id
        expect(response).to be_success
        expect(individual_recipient.reload).to be_delivered
      end

      it 'read state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        individual_recipient.deliver!
        individual_recipient.mark_as_read!
        patch :deliver, format: :json, id: @message.id
        expect(response).to be_success
        expect(individual_recipient.reload).to be_read
      end
    end

    context 'individual message' do
      before do
        friend.friends << user
        @message = friend.sent_messages.create!(recipient: user, text_content: 'This is a test!')
      end

      it_behaves_like 'deliver examples'
    end

    context 'group message' do
      before do
        friend.friends << user
        group = friend.groups.last
        group.friendships << friend.friendships.find_by(friend_id: user.id)
        @message = friend.sent_messages.create!(recipient: group, text_content: 'This is a test!')
      end

      it_behaves_like 'deliver examples'
    end
  end

  describe 'GET show' do
    before do
      friend.friends << user
    end

    shared_examples 'show examples' do
      it 'draft state' do
        get :show, format: :json, id: @message.id
        expect(response).to be_not_found
        expect(json_response).to eq({ 'error' => subject.t('.not_found') })
      end

      it 'sent state' do
        @message.mark_as_unread!
        get :show, format: :json, id: @message.id
        expect(response).to be_success
        expect(response).to render_template(:show)
      end

      it 'delivered state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        individual_recipient.deliver!
        get :show, format: :json, id: @message.id
        expect(response).to be_success
        expect(response).to render_template(:show)
      end

      it 'read state' do
        @message.mark_as_unread!
        individual_recipient = @message.individual_recipients.find_by(user_id: user.id)
        individual_recipient.deliver!
        individual_recipient.mark_as_read!
        get :show, format: :json, id: @message.id
        expect(response).to be_success
        expect(response).to render_template(:show)
      end
    end

    context 'individual message' do
      before do
        @message = friend.sent_messages.create!(recipient: user, text_content: 'This is a test!')
      end

      it_behaves_like 'show examples'
    end

    context 'group message' do
      before do
        @group = friend.groups.last
        @group.friendships << friend.friendships.find_by(friend_id: user.id)
        @message = friend.sent_messages.create!(recipient: @group, text_content: 'This is a test!')
      end

      it_behaves_like 'show examples'
    end
  end
end

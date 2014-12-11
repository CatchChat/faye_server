require 'rails_helper'

RSpec.describe Message, :type => :model do
  let(:user) { create(:user, username: 'user') }
  let(:friend) { create(:user, username: 'friend') }

  context 'Should create individual_recipients after transition draft to unread' do

    it 'user message' do
      message = user.messages.create!(recipient: friend, text_content: 'This is a test!')
      expect(message).to be_draft
      expect(message.individual_recipients).to be_blank
      message.mark_as_unread!
      expect(message.individual_recipients).to be_present
    end

    it 'group message' do
      friend1 = create(:user, username: 'friend1')
      Friendship.create_friendships(user, friend)
      Friendship.create_friendships(user, friend1)
      group = user.groups.first
      group.friendships << user.friendships.find_by(friend: friend)
      group.friendships << user.friendships.find_by(friend: friend1)

      message = user.messages.create!(recipient: group, text_content: 'This is a test!')
      expect(message).to be_draft
      expect(message.individual_recipients).to be_blank
      message.mark_as_unread!
      expect(message.individual_recipients.count).to eq 2
    end
  end

  context '#push_notification' do

    it 'user message' do
      message = user.messages.create!(recipient: friend, text_content: 'This is a test!')
      message.mark_as_unread!
      allow(Pusher).to receive(:push_to_user).once
      message.push_notification
    end

    it 'group message' do
      friend1 = create(:user, username: 'friend1')
      Friendship.create_friendships(user, friend)
      Friendship.create_friendships(user, friend1)
      group = user.groups.first
      group.friendships << user.friendships.find_by(friend: friend)
      group.friendships << user.friendships.find_by(friend: friend1)

      message = user.messages.create!(recipient: group, text_content: 'This is a test!')
      message.mark_as_unread!
      allow(Pusher).to receive(:push_to_user).twice
      message.push_notification
    end
  end
end

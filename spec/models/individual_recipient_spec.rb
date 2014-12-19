require 'rails_helper'

RSpec.describe IndividualRecipient, :type => :model do
  let(:user) { create(:user, username: 'user') }
  let(:friend) { create(:user, username: 'friend') }

  context 'Should update message state when mark as read' do

    it 'use message' do
      message = user.messages.create!(recipient: friend, text_content: 'This is a test!')
      message.mark_as_unread!
      expect(message).to be_unread
      message.individual_recipients.first.mark_as_read!
      expect(message.reload).to be_read
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
      expect(message).to be_unread
      message.individual_recipients.first.mark_as_read!
      expect(message.reload).to be_unread
      message.individual_recipients.last.mark_as_read!
      expect(message.reload).to be_read
    end
  end

  context '#update_counters' do

    it 'increment counters if state is sent' do
      count = friend.unread_messages_count.value
      message = user.messages.create!(recipient: friend, text_content: 'This is a test!')
      message.mark_as_unread
      expect(friend.unread_messages_count.value).to eq count + 1
    end

    it 'do not update counters if state from sent to delivered' do
      message = user.messages.create!(recipient: friend, text_content: 'This is a test!')
      message.mark_as_unread
      individual_recipient = message.individual_recipients.first
      count = friend.unread_messages_count.value
      individual_recipient.deliver!
      expect(friend.unread_messages_count.value).to eq count
    end

    it 'decrement counters if state from sent to read' do
      message = user.messages.create!(recipient: friend, text_content: 'This is a test!')
      message.mark_as_unread
      individual_recipient = message.individual_recipients.first
      count = friend.unread_messages_count.value
      individual_recipient.mark_as_read!
      expect(friend.unread_messages_count.value).to eq count - 1
    end
  end
end

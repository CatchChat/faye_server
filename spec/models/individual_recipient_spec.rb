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
end

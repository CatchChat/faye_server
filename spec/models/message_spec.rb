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
      expect(Pusher).to receive(:push_to_user).with(
        friend,
        content: I18n.t(
          'notification.sent_message_to_you',
          friend_name: user.name_by_friend(friend),
          media_type: Message.human_attribute_name('text')
        ),
        extras: { type: 'message', subtype: 'text' },
        content_available: 1
      )
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

      expect(Pusher).to receive(:push_to_user).with(
        friend,
        content: I18n.t(
          'notification.sent_message_to_you',
          friend_name: user.name_by_friend(friend),
          media_type: Message.human_attribute_name('text')
        ),
        extras: { type: 'message', subtype: 'text' },
        content_available: 1
      )

      expect(Pusher).to receive(:push_to_user).with(
        friend1,
        content: I18n.t(
          'notification.sent_message_to_you',
          friend_name: user.name_by_friend(friend1),
          media_type: Message.human_attribute_name('text')
        ),
        extras: { type: 'message', subtype: 'text' },
        content_available: 1
      )

      message.push_notification
    end
  end

  context 'after read' do

    it 'delete attachments storage' do
      attachment = create(:attachment)
      message = user.messages.create!(
        recipient: friend,
        text_content: 'This is a test!',
        media_type: Message.media_types[:image],
        attachments: [attachment]
      )
      message.mark_as_unread!
      expect(attachment).to receive(:queue_to_delete_storage)
      message.mark_as_read!
    end
  end

  context '.create_by_official_message!' do
    before do
      Friendship.create_friendships(user, friend)
    end

    it 'has parent' do
      parent = user.messages.first
      message = Message.create_by_official_message!(user, friend, parent)
      expect(message.sender).to eq user
      expect(message.recipient).to eq friend
      expect(message).to be_unread
      expect(message.parent).to eq parent
    end

    it 'no parent' do
      message = Message.create_by_official_message!(user, friend)
      expect(message.sender).to eq user
      expect(message.recipient).to eq friend
      expect(message).to be_unread
      expect(message.parent).to eq nil
    end
  end
end

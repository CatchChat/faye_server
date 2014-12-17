require 'rails_helper'

RSpec.describe User, :type => :model, sidekiq: :inline do
  let(:user) { create(:user, username: 'user', mobile: '18668158203', mobile_verified: true) }
  let(:friend) { create(:user, username: 'friend', mobile: '15158166372', mobile_verified: true) }

  describe '#name_by_friend' do
    it 'is friend' do
      Friendship.create_friendships(user, friend)
      user.friendships.find_by(friend: friend).update!(remarked_name: 'remarked_name1')
      friend.friendships.find_by(friend: user).update!(remarked_name: 'remarked_name2')
      expect(user.name_by_friend(friend)).to eq 'remarked_name1'
      expect(friend.name_by_friend(user)).to eq 'remarked_name2'
    end

    it 'is not friend and is contacts friend' do
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
      user.contacts.create!(name: 'friend_contact_name', number: friend.mobile)
      friend.contacts.create!(name: 'user_contact_name', number: user.mobile)
      expect(user.name_by_friend(friend)).to eq 'user_contact_name'
      expect(friend.name_by_friend(user)).to eq 'friend_contact_name'
    end

    it 'is not friend and is not contacts friend' do
      expect(user.friends).to_not include friend
      expect(friend.friends).to_not include user
      expect(user.name_by_friend(friend)).to eq user.name
      expect(friend.name_by_friend(user)).to eq friend.name
    end
  end

  it '#report_message' do
    Friendship.create_friendships(user, friend)
    attachment = create(:attachment)
    message = user.messages.create!(
      recipient: friend,
      text_content: 'This is a test!',
      media_type: Message.media_types[:image],
      attachments: [attachment]
    )
    message.mark_as_unread!

    report = friend.report_message(message)
    expect(report).to be_persisted
    expect(report.message).to eq message
    expect(report.whistleblower).to eq friend
    expect(report.sender).to eq user
    expect(report.recipient).to eq friend
    expect(report.media_type).to eq message.attributes['media_type']
    expect(report.text_content).to eq message.text_content
    expect(report.parent_id).to eq message.parent_id
    expect(report.state).to eq message.state
    expect(report.longitude).to eq message.longitude
    expect(report.latitude).to eq message.latitude
    expect(report.battery_level).to eq message.battery_level
    expect(report.attachments).to eq([attachment.reload])
    expect(attachment).to be_reserved
  end

  it '#generate_pusher_id' do
    new_user = User.new
    new_user.send :generate_pusher_id
    expect(new_user.pusher_id).to be_present

    new_user = User.new(pusher_id: 'pusher_id')
    new_user.send :generate_pusher_id
    expect(new_user.pusher_id).to eq 'pusher_id'
  end

  it '#push_joined_notification' do
    user1 = create(:user, username: 'user1', mobile_verified: true, mobile: '15158113320')
    user1.contacts.create!(name: 'user a', number: user.normalized_mobile)
    user2 = create(:user, username: 'user2', mobile_verified: false, mobile: '15158113321')
    user2.contacts.create!(name: 'user b', number: user.normalized_mobile)

    expect(Pusher).to receive(:push_to_user).with(
      user1,
      content: I18n.t(
        'notification.contact_registered',
        contact_name: 'user a',
        username: user.username
      ),
      extras: { type: 'contact_join' }
    )

    expect(Pusher).to receive(:push_to_user).with(
      user2,
      content: I18n.t(
        'notification.contact_registered',
        contact_name: 'user b',
        username: user.username
      ),
      extras: { type: 'contact_join' }
    )

    user.push_joined_notification
  end
end

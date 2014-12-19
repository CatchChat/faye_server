require 'rails_helper'
require 'vcr_helper'
describe Pusher do
  let(:user) { FactoryGirl.create(:user, pusher_id: '53a7e7535637cabb5041171d') }

  describe '#push_to_user' do

    it 'no current access token' do
      AccessToken.current = nil

      options = {
        content: "xxx", extras: { key1: "value1", key2: "value2" }, title: I18n.t('catch_chat'), badge: 0, accounts: ["53a7e7535637cabb5041171d"]
      }

      expect_any_instance_of(XingePusher).to receive(:push_to_accounts).with(options)
      expect_any_instance_of(JpushPusher).to receive(:push_to_accounts).with(options)

      Pusher.push_to_user(
        user,
        content: 'xxx',
        extras: { key1: 'value1', key2: 'value2' }
      )
    end

    it 'badge' do
      AccessToken.current = nil
      user.unread_messages_count.value = 10
      user.pending_friend_requests_count.value = 10

      options = {
        content: "xxx", extras: { key1: "value1", key2: "value2" }, title: I18n.t('catch_chat'), badge: 20, accounts: ["53a7e7535637cabb5041171d"]
      }

      expect_any_instance_of(XingePusher).to receive(:push_to_accounts).with(options)
      expect_any_instance_of(JpushPusher).to receive(:push_to_accounts).with(options)

      Pusher.push_to_user(
        user,
        content: 'xxx',
        extras: { key1: 'value1', key2: 'value2' }
      )
    end

    # it 'success' do
    #   VCR.use_cassette('push_to_user') do
    #     result = Pusher.push_to_user(
    #       user,
    #       content: 'xxx',
    #       environment: false
    #     )
    #     expect(result).to eq true
    #   end
    # end
  end
end

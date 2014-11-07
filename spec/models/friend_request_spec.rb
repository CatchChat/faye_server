require 'rails_helper'
require 'timecop'

RSpec.describe FriendRequest, :type => :model do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  describe 'Touch received_friend_requests_updated_at for friend' do

    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    it 'when create' do
      expect(friend.received_friend_requests_updated_at).to be_nil
      FriendRequest.create!(user_id: user.id, friend_id: friend.id)
      expect(friend.received_friend_requests_updated_at.to_i).to eq Time.zone.now.to_i
    end

    it 'when destroy' do
      friend_request = FriendRequest.create!(user_id: user.id, friend_id: friend.id)
      friend.received_friend_requests_updated_at = nil
      friend_request.destroy
      expect(friend.received_friend_requests_updated_at.to_i).to eq Time.zone.now.to_i
    end

    it 'when update' do
      friend_request = FriendRequest.create!(user_id: user.id, friend_id: friend.id)
      friend.received_friend_requests_updated_at = nil
      friend_request.accept
      expect(friend.received_friend_requests_updated_at.to_i).to eq Time.zone.now.to_i
    end
  end
end

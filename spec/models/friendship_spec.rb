require 'rails_helper'
require 'timecop'

RSpec.describe Friendship, :type => :model do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  describe 'Should touch friendships_updated_at for user' do

    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    it 'when create' do
      expect(user.friendships_updated_at.to_i).to eq 0
      Friendship.create!(user_id: user.id, friend_id: friend.id)
      expect(user.friendships_updated_at.to_i).to eq Time.zone.now.to_i
    end

    it 'when destroy' do
      friendship = Friendship.create!(user_id: user.id, friend_id: friend.id)
      user.friendships_updated_at = 0
      expect(user.friendships_updated_at.to_i).to eq 0
      friendship.destroy
      expect(user.friendships_updated_at.to_i).to eq Time.zone.now.to_i
    end

    it 'when update' do
      friendship = Friendship.create!(user_id: user.id, friend_id: friend.id)
      user.friendships_updated_at = 0
      expect(user.friendships_updated_at.to_i).to eq 0
      friendship.update(remarked_name: 'test')
      expect(user.friendships_updated_at.to_i).to eq Time.zone.now.to_i
    end
  end

  it 'Should increasing friends_count for user when create' do
    expect(user.friends_count).to eq 0
    Friendship.create!(user_id: user.id, friend_id: friend.id)
    expect(user.friends_count).to eq 1
  end

  it 'Should decreasing friends_count for user when destroy' do
    friendship = Friendship.create!(user_id: user.id, friend_id: friend.id)
    expect(user.friends_count).to eq 1
    friendship.destroy
    expect(user.friends_count).to eq 0
  end
end

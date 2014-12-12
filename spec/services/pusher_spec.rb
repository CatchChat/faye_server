require 'rails_helper'
require 'vcr_helper'
describe Pusher do
  let(:user) { FactoryGirl.create(:user) }

  describe '#push_to_user' do

    # it 'no current access token' do
    #   AccessToken.current = nil
    #   expect {
    #     Pusher.push_to_user(
    #       user.id,
    #       title: 'xxx',
    #       content: 'xxx',
    #       extras: { key1: 'value1', key2: 'value2' },
    #       badge: 10,
    #       sound: 'bub3.caf',
    #       environment: false
    #     )
    #   }.to_not raise_error
    # end

    # it 'success' do
    #   AccessToken.current = AccessToken.create!(
    #     active: true,
    #     token: user.generate_token,
    #     client: AccessToken.clients[:company],
    #     expired_at: 3.days.since
    #   )

    #   VCR.use_cassette('push_to_user') do
    #     result = Pusher.push_to_user(
    #       user,
    #       title: 'xxx',
    #       content: 'xxx',
    #       extras: { key1: 'value1', key2: 'value2' },
    #       badge: 10,
    #       sound: 'bub3.caf',
    #       environment: false
    #     )
    #     expect(result).to eq true
    #   end
    # end
  end
end

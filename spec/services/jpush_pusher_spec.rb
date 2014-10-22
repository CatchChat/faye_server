require 'rails_helper'
require 'vcr_helper'
describe JpushPusher do

  subject { JpushPusher.new(id: Settings.jpush.company_id, key: Settings.jpush.company_key) }

  it '#push_to_single_account' do
    VCR.use_cassette('jpush_pusher_push_to_single_account') do
      result = subject.push_to_single_account(
        title: 'xxx',
        content: 'xxx',
        extras: { key1: 'value1', key2: 'value2' },
        badge: 10,
        sound: 'bub3.caf',
        environment: false,
        account: '53fa035744d4068444adbd53'
      )
      expect(result).to eq true
    end
  end
end

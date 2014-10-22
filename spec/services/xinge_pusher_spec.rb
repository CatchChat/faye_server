require 'rails_helper'
require 'vcr_helper'
describe XingePusher do

  subject {
    XingePusher.new(
      ios: Settings.xinge.ios.to_h.symbolize_keys,
      android: Settings.xinge.android.to_h.symbolize_keys
    )
  }

  it '#push_to_single_account' do
    VCR.use_cassette('xinge_pusher_push_to_single_account') do
      result = subject.push_to_single_account(
        title: 'xxx',
        content: 'xxx',
        extras: { key1: 'value1', key2: 'value2' },
        badge: 10,
        sound: 'bub3.caf',
        environment: false,
        account: '53951bc5c2bba5ca47361472',
        device_token: '8c27dabc4c0f7810e078a9c286f2afeec2ad567016985b3e19c4f846a1acd8a8'
      )
      expect(result).to eq true
    end
  end
end

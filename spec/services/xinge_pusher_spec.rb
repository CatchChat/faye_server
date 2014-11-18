require 'rails_helper'
require 'vcr_helper'
describe XingePusher do

  subject {
    XingePusher.new(
      ios: Settings.xinge.ios.to_h.symbolize_keys,
      android: Settings.xinge.android.to_h.symbolize_keys
    )
  }

  it '#push_to_accounts' do
    VCR.use_cassette('xinge_pusher_push_to_accounts') do
      result = subject.push_to_accounts(
        title: 'xxx',
        content: 'xxx',
        extras: { key1: 'value1', key2: 'value2' },
        badge: 10,
        sound: 'bub3.caf',
        environment: false,
        accounts: '53951bc5c2bba5ca47361472'
      )
      expect(result).to eq true
    end
  end
end

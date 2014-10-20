require 'rails_helper'
require 'xinge'
require 'timecop'
require 'vcr_helper'
describe Xinge::Pusher do

  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  let(:android_pusher)  { Xinge::Pusher.new(Settings.xinge.android.id, Settings.xinge.android.key) }
  let(:android_message) { Xinge::AndroidMessage.new(title: '秒视', content: 'this is a test.') }
  let(:ios_pusher)  { Xinge::Pusher.new(Settings.xinge.ios.id, Settings.xinge.ios.key) }
  let(:ios_message) { Xinge::IOSMessage.new(alert: 'this is a test.') }

  it '#common_params' do
    expect(ios_pusher.common_params).to eq({
      access_id: Settings.xinge.ios.id,
      timestamp: Time.now.to_i,
      valid_time: 600
    })

    expect(android_pusher.common_params).to eq({
      access_id: Settings.xinge.android.id,
      timestamp: Time.now.to_i,
      valid_time: 600
    })
  end

  context '#push_to_single_device' do
    it 'android' do
      device_token = '0f58b34d634088ae4d0d9bc061c633f9b25432fe'
      VCR.use_cassette('xinge/android_push_to_single_device') do
        response = android_pusher.push_to_single_device(device_token, android_message)
        expect(response.success?).to eq true
      end
    end

    it 'ios' do
      device_token = '8c27dabc4c0f7810e078a9c286f2afeec2ad567016985b3e19c4f846a1acd8a8'
      VCR.use_cassette('xinge/ios_push_to_single_device') do
        response = ios_pusher.push_to_single_device(device_token, ios_message, environment: Xinge::Pusher::IOS_ENV_DEV)
        expect(response.success?).to eq true
      end
    end
  end

  context '#push_to_single_account' do
    it 'android' do
      VCR.use_cassette('xinge/android_push_to_single_account') do
        response = android_pusher.push_to_single_account('53951bc5c2bba5ca47361472', android_message, device_type: Xinge::Pusher::DEVICE_TYPE_ANDROID)
        expect(response.success?).to eq true
      end
    end

    it 'ios' do
      VCR.use_cassette('xinge/ios_push_to_single_account') do
        response = ios_pusher.push_to_single_account('53951bc5c2bba5ca47361472', ios_message, device_type: Xinge::Pusher::DEVICE_TYPE_IOS, environment: Xinge::Pusher::IOS_ENV_DEV)
        expect(response.success?).to eq true
      end
    end
  end

  # context '#push_to_all_devices' do
  #   it 'android' do
  #     VCR.use_cassette('xinge/android_push_to_all_devices') do
  #       response = android_pusher.push_to_all_devices(android_message, device_type: Xinge::Pusher::DEVICE_TYPE_ANDROID)
  #       expect(response.success?).to eq true
  #     end
  #   end

  #   it 'ios' do
  #     VCR.use_cassette('xinge/ios_push_to_all_devices') do
  #       response = ios_pusher.push_to_all_devices(ios_message, device_type: Xinge::Pusher::DEVICE_TYPE_IOS, environment: Xinge::Pusher::IOS_ENV_DEV)
  #       expect(response.success?).to eq true
  #     end
  #   end
  # end
end

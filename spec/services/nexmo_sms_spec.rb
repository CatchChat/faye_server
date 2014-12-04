require 'rails_helper'
require 'timecop'
require 'vcr_helper'
require 'services_helper'
describe Sms do
  before do
    Timecop.freeze(Time.local(2014,12,4,15,20))
  end

  after do
    Timecop.return
  end

  context 'nexmo' do
    before do
      key              = ENV["nexmo_key"]
      secret           = ENV["nexmo_secret"]
      @init_hash       = {key: key, secret: secret}
      @nexmo_client    = NexmoSms.new @init_hash
      @sms             = Sms.new(@nexmo_client)
    end

    subject {@sms}

    it "send sms message" do
      VCR.use_cassette('nexmo_send_sms') do
        message_id = @sms.send_sms mobile: '+8615626044835', message: 'Test Message'
        expect(message_id).to include "00"

      end
    end
  end
end

require 'rails_helper'

describe SmsVerificationCode do

  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  it '#send_msg' do
    sms_code = user.sms_verification_codes.last
    expect_any_instance_of(Sms).to receive(:send_sms).with({:mobile=>sms_code.mobile, :message=>"test msg"}).and_return(true)
    sms_code.send_msg('test msg')

  end

  it "#verify_token" do
    sms_code = user.sms_verification_codes.last
    expect(user.mobile_verified).to be false
    expect(sms_code.active).to be true
    SmsVerificationCode.verify_token(mobile: sms_code.mobile, phone_code: sms_code.phone_code, token: sms_code.token)
    sms_code.reload
    expect(sms_code.active).to be false
  end
end

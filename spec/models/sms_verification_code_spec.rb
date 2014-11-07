require 'rails_helper'

describe SmsVerificationCode do

  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  it 'send_msg' do
    sms_code = user.sms_verification_codes.last
    expect_any_instance_of(Sms).to receive(:send_sms).with({:mobile=>sms_code.mobile, :message=>"test msg"}).and_return(true)
    sms_code.send_msg('test msg')

  end
end

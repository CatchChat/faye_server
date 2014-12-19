require 'rails_helper'

describe Users::PasswordsController do
  render_views
  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'change password with current password, new password and new password confirm then remove old access tokens' do
    sign_in user
    AccessToken.create user_id: subject.current_user.id, token: 'asdsd'
    put :change_password, current_password: 'ruanwztest', new_password: 'new_password', new_password_confirm: 'new_password', format: 'json'

    expect(subject.current_user.password).to eq 'new_password'
    expect(AccessToken.find_by(user_id: subject.current_user.id)).to be nil
  end

  it 'send sms token when provide username' do
    expect_any_instance_of(SmsVerificationCode).to receive(:send_msg)
    post :send_verify_code, username: user.username, format: 'json'

  end

  it 'send sms token when provide mobile info' do
    expect_any_instance_of(SmsVerificationCode).to receive(:send_msg)
    post :send_verify_code, mobile: user.mobile, phone_code: '86', format: 'json'

  end
  it 'change password with sms token then remove old access tokens' do
    user = User.create username: 'passworduser', password: 'oldpassword', mobile: '111222333', phone_code: '86'
    AccessToken.create user_id: user.id, token: 'asdsd'
    sms_token = SmsVerificationCode.create mobile: user.mobile, user_id: user.id, token: '123', active: true, expired_at: Time.zone.now + 3600
    post :change_password, token: sms_token.token, mobile: user.mobile, new_password: 'abcabc123', new_password_confirm: 'abcabc123', phone_code: '86'
    expect(user.reload.valid_password?('abcabc123')).to eq true
    expect(AccessToken.find_by(user_id: user.id)).to be nil
  end

end

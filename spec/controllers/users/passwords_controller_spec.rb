require 'rails_helper'

describe Users::PasswordsController do
  render_views
  let(:user) {FactoryGirl.create(:user, mobile: '1234567')}
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'change password with current password, new password and new password confirm' do
    sign_in user
    put :change_password, current_password: 'ruanwztest', new_password: 'new_password', new_password_confirm: 'new_password', format: 'json'

    expect(subject.current_user.password).to eq 'new_password'
  end

  it 'send sms token' do
    expect_any_instance_of(SmsVerificationCode).to receive(:send_msg).and_return(true)
    post :send_verify_code, mobile: user.mobile, format: 'json'

  end

  it 'change password with sms token' do
    user = User.create username: 'passworduser', password: 'oldpassword', mobile: '111222333'
    sms_token = SmsVerificationCode.create mobile: user.mobile, user_id: user.id, token: '123', active: true, expired_at: Time.now + 3600
    post :change_password, token: sms_token.token, mobile: user.mobile, new_password: 'abcabc123', new_password_confirm: 'abcabc123'
    expect(user.reload.valid_password?('abcabc123')).to eq true
  end

end

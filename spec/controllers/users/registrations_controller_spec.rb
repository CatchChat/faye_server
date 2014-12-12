require 'rails_helper'

describe Users::RegistrationsController do
  render_views

  before do
    create(:user, username: Settings.official_accounts.first, mobile: '53534')
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  it 'reject invalid params to create a new user ' do
    post :create, username: 'n', password: 'abcabc123', mobile: '6767', phone_code: '86', format: 'json'
    expect(response.body).to include 'invalid user data'
  end

  it 'block the user when created' do
    expect_any_instance_of(SmsVerificationCode).to receive(:send_msg).and_return(true)
    post :create, username: 'newusername', password: 'abcabc123', mobile: '6767', phone_code: '86', format: 'json'
    expect(User.find_by(username: 'newusername')).to be_an_instance_of(User)
    expect(User.find_by(username: 'newusername').valid_password?('abcabc123')).to be true
    expect(User.find_by(username: 'newusername').blocked?).to be true
    expect(User.find_by(username: 'newusername').phone_code).to eq '86'
    expect(response.body).to include '"state_name":"blocked"'
    expect(response.body).to include 'true'
  end

  it 'update the user state when receive sms token' do
    @user   = FactoryGirl.create(:user, phone_code: '86', mobile: '1234567', state: User::STATES[:blocked])
    put :update_token, username: @user.username, token: @user.sms_verification_codes.last.token, mobile: @user.mobile, phone_code: '86', format: 'json'
    expect(@user.reload.state_name).to be :active
    expect(response.body).to include '"state_name":"active"'
  end
end

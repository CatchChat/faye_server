require 'rails_helper'

describe Users::RegistrationsController do
  render_views

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  it 'reject invalid params to create a new user ' do
    post :create, username: 'n', password: 'abcabc123', mobile: '6767', format: 'json'
    expect(response.body).to include 'invalid user data'
  end

  it 'block the user when created' do
    expect_any_instance_of(SmsVerificationCode).to receive(:send_msg).and_return(true)
    post :create, username: 'newusername', password: 'abcabc123', mobile: '6767', format: 'json'
    expect(User.find_by(username: 'newusername')).to be_an_instance_of(User)
    expect(User.find_by(username: 'newusername').valid_password?('abcabc123')).to be true
    expect(User.find_by(username: 'newusername').blocked?).to be true
    expect(response.body).to include '"state_name":"blocked"'
    expect(response.body).to include '"sent_sms":true'
  end

  it 'update the user state when receive sms token' do
    @user   = FactoryGirl.create(:user, mobile: '1234567', state: User::STATES[:blocked])
    put :update_token, username: @user.username, token: @user.sms_verification_codes.last.token, mobile: @user.mobile, format: 'json'
    expect(@user.reload.state_name).to be :active
    # expect(User.find_by(username: 'newusername')).to be_an_instance_of(User)
  end
end

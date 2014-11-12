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
    expect(response.body).to include '"sent_sms":true'
  end

end

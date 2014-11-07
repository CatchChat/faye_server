require 'rails_helper'

describe Users::SessionsController do
  render_views
  before do
    @user   = FactoryGirl.create(:user, mobile: '1234567')
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'logins with username and password then returns token json' do
    post :create,login: 'ruanwztest', password: 'ruanwztest', :format => 'json'
    expect(response.body).to include 'ruanwztest'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'logins with node token then returns token json' do
    post :create, login: 'ruanwztest', password: 'node', :format => 'json'
    expect(response.body).to include 'ruanwztest'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'logins with mobile and sms verification code then returns token json' do
    post :create_by_mobile, login: @user.mobile, password: @user.sms_verification_codes.last.token, :format => 'json'
    expect(response.body).to include 'mobile'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'request to send sms code' do
    # TODO: expect_any_instance_of is a design smell
    expect_any_instance_of(SmsVerificationCode).to receive(:send_msg).and_return(true)
    post :send_verify_code, login: @user.mobile, :format => 'json'
    expect(response.body).to include 'sent'
  end
end

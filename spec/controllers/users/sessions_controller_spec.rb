require 'rails_helper'

describe Users::SessionsController do
  render_views
  before do
    @user   = FactoryGirl.create(:user, mobile: '1234567')
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'logins with username/password and expiring 0 then returns always active token json' do
    post :create,login: 'ruanwztest', password: 'ruanwztest', expiring: 0, :format => 'json'
    expect(@user.access_tokens.last.active).to be true
    expect(@user.access_tokens.last.expired_at).to be nil
    expect(response.body).to include 'ruanwztest'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'logins with username/password and no expiring then returns 7 days active token json' do
    post :create,login: 'ruanwztest', password: 'ruanwztest', :format => 'json'
    expect(@user.access_tokens.last.active).to be true
    expect(@user.access_tokens.last.expired_at.to_i/100).to eq (Time.now.to_i + 3600*24*7)/100
    expect(response.body).to include 'ruanwztest'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'logins with username/password and expiring then returns exact expired_at active token json' do
    post :create,login: 'ruanwztest', password: 'ruanwztest', expiring: 1000, :format => 'json'
    expect(@user.access_tokens.last.active).to be true
    expect(@user.access_tokens.last.expired_at.to_i/10).to eq (Time.now.to_i + 1000)/10
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

    post :send_verify_code, login: @user.mobile, expiring: 1000, :format => 'json'
    expect(@user.sms_verification_codes.last.active).to be true
    expect(@user.sms_verification_codes.last.expired_at.to_i/10).to eq (Time.now.to_i + 1000)/10
    expect(response.body).to include 'sent'
  end
end

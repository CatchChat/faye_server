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
    expect(@user.access_tokens.last.client).to eq "official"
    expect(response.body).to include 'ruanwztest'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'logins with username/password and no expiring then returns 7 days active token json' do
    post :create,login: 'ruanwztest', password: 'ruanwztest', client: 1, :format => 'json'
    expect(@user.access_tokens.last.active).to be true
    expect(@user.access_tokens.last.expired_at.to_i/100).to eq (Time.zone.now.to_i + 3600*24*7)/100
    expect(@user.access_tokens.last.client).to eq "company"
    expect(response.body).to include 'ruanwztest'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'logins with username/password and expiring then returns exact expired_at active token json' do
    post :create,login: 'ruanwztest', password: 'ruanwztest', expiring: 1000, :format => 'json'
    expect(@user.access_tokens.last.active).to be true
    expect(@user.access_tokens.last.expired_at.to_i/100).to eq (Time.zone.now.to_i + 1000)/100
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
    post :create_by_mobile, mobile: @user.mobile, verify_code: @user.sms_verification_codes.last.token, phone_code: @user.phone_code, :format => 'json'
    expect(response.body).to include 'mobile'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'request to send sms code' do

    sign_in @user
    expect_any_instance_of(SmsVerificationCode).to receive(:send_msg).and_return(true)

    post :send_verify_code, mobile: @user.mobile, phone_code: @user.phone_code, expiring: 1000, :format => 'json'
    expect(@user.sms_verification_codes.last.active).to be true
    expect(@user.sms_verification_codes.last.expired_at.to_i/10).to eq (Time.zone.now.to_i + 1000)/10
    expect(json_response.keys).to eq ['mobile', 'status']
    expect(json_response['status']).to eq 'sms sent'
  end

  it 'verify if sms verification ok' do
    create :sms_verification_code, mobile: '454545', token: 'thesecret', user_id: @user.id
    get :check_verify_code, phone_code: '86', mobile: '454545', token: 'thesecret'
    expect(json_response['status']).to eq 'mobile verified'
  end
end

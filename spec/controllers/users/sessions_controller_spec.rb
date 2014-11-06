require 'rails_helper'

describe Users::SessionsController do
  render_views
  before do
    @user   = FactoryGirl.create(:user)
    @mobile_user   = FactoryGirl.create(:mobile_user)
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
    post :create, login: '123456789', password: 'test-token', :format => 'json'
    expect(response.body).to include 'mobile'
    expect(response.body).to include 'access_token'
    expect(response.body).not_to include 'null'
  end

  it 'request to send sms code' do
    allow(controller).to receive(:send_sms).and_return(true)
    get :new, login: '123456789', :format => 'json'
    expect(response.body).to include 'sent'
  end
end

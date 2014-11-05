require 'rails_helper'

describe Users::SessionsController do
  render_views
  before do
    @user   = FactoryGirl.create(:user)
  end

  it 'returns token json' do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    post :create, username: 'ruanwztest', password: 'ruanwztest', :format => 'json'
    puts response.body
    expect(response.body).to include 'ruanwztest'
    expect(response.body).to include 'token'
  end
end

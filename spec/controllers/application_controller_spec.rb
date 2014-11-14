require 'rails_helper'

class TestsController < ApiController

  def index
    render json: { ok: true }
  end
end

RSpec.describe TestsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }
  before do
    Rails.application.routes.draw do
      resources :tests, only: :index
    end
  end

  after do
    Rails.application.reload_routes!
  end

  it 'access token not exist return error info in return json' do
    request.headers['AuthorizationToken'] = 'xxx'
    get :index
    expect(response.body).to include "Token: Access denied"
    expect(response.status).to be 401
  end
end

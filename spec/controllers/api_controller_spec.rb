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

  context 'ApiController#set_locale' do

    before do
      sign_in user
    end

    it 'Accept-Language is wrong' do
      request.headers['Accept-Language'] = 'xxx'
      get :index
      expect(I18n.locale).to eq :'zh-CN'
    end

    it 'Accept-Language is correct' do
      request.headers['Accept-Language'] = 'en'
      get :index
      expect(I18n.locale).to eq :en
    end
  end

  context 'ApiController#authenticate_user' do

    it 'unauthorized' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it 'authenticated' do
      sign_in user
      get :index
      expect(response).to be_success
    end
  end

  context 'ApiController#set_time_zone' do

    it 'The time_zone is wrong' do
      user.update!(time_zone: 'xxx')
      sign_in user
      get :index
      expect(Time.zone.name).to eq 'Beijing'
    end

    it 'The time_zone is correct' do
      user.update!(time_zone: 'UTC')
      sign_in user
      get :index
      expect(Time.zone.name).to eq 'UTC'
    end
  end

  context 'ApiController#set_rate_limit' do

    it 'the response should have rate limit data' do
      get :index
      expect(response.headers).to be_has_key('X-RateLimit-Limit')
      expect(response.headers).to be_has_key('X-RateLimit-Remaining')
      expect(response.headers).to be_has_key('X-RateLimit-Reset')
    end
  end
end

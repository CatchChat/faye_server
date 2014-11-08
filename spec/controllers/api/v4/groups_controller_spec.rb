require 'rails_helper'

RSpec.describe Api::V4::GroupsController, :type => :controller do
  let(:current_user) { subject.current_user }
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }

  before do
    sign_in user
  end

  it 'GET index' do
    get :index, format: :json
    expect(response).to be_success
    expect(response).to render_template(:index)
  end

  describe 'POST create' do

    it 'should render :unprocessable_entity when name is already used' do
      name = 'testgroup'
      user.groups.create!(name: name)
      post :create, name: name, format: :json
      expect(response).to be_unprocessable
    end

    it 'should render :success when create success' do
      post :create, name: 'testgroup', format: :json
      expect(response).to be_success
      expect(response).to render_template(:create)
      expect(current_user.groups.last.name).to eq 'testgroup'
    end
  end

  describe 'PUT update' do

    it 'should render :not_found when group is not found' do
      put :update, id: 0, name: 'testgroup1', format: :json
      expect(response).to be_not_found
    end

    it 'should render :unprocessable_entity when name is already used' do
      group = user.groups.create!(name: 'testgroup')
      user.groups.create!(name: 'testgroup1')
      put :update, id: group.id, name: 'testgroup1', format: :json
      expect(response).to be_unprocessable
    end

    it 'should render :success when update success' do
      group = user.groups.create!(name: 'testgroup')
      put :update, id: group.id, name: 'testgroup1', format: :json
      expect(response).to be_success
      expect(response).to render_template(:update)
      expect(group.reload.name).to eq 'testgroup1'
    end
  end

  describe 'GET show' do

    it 'should render :not_found when group is not found' do
      get :show, id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'should render :success when show success' do
      group = user.groups.create!(name: 'testgroup')
      get :show, id: group.id, format: :json
      expect(response).to be_success
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE destroy' do

    it 'should render :not_found when group is not found' do
      get :show, id: 0, format: :json
      expect(response).to be_not_found
    end

    it 'should render :success when destroy success' do
      group = user.groups.create!(name: 'testgroup')
      delete :destroy, id: group.id, format: :json
      expect(response).to be_success
      expect { group.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

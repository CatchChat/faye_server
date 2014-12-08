require 'rails_helper'

RSpec.describe Api::V4::UserController, :type => :controller do

  let(:user) { FactoryGirl.create(:user, username: 'user', mobile_verified: true, mobile: '15158166666', phone_code: '86') }

  before do
    sign_in user
  end

  it 'GET may_know_friends' do
    current_binding = binding

    1.upto(8) do |index|
      current_binding.local_variable_set("friend#{index}", create(:user, username: "friend#{index}"))
    end

    1.upto(5) do |index|
      Friendship.create_friendships(user, current_binding.local_variable_get("friend#{index}"))
    end

    2.upto(5) do |index|
      Friendship.create_friendships(current_binding.local_variable_get(:friend6), current_binding.local_variable_get("friend#{index}"))
    end

    3.upto(5) do |index|
      Friendship.create_friendships(current_binding.local_variable_get(:friend7), current_binding.local_variable_get("friend#{index}"))
    end

    4.upto(5) do |index|
      Friendship.create_friendships(current_binding.local_variable_get(:friend8), current_binding.local_variable_get("friend#{index}"))
    end

    get :may_know_friends, format: :json
    expect(response).to be_success
    expect(json_response).to eq({
      "friends"=> [
        {
          "id"                  => current_binding.local_variable_get(:friend6).id,
          "username"            => "friend6",
          "nickname"            => nil,
          "name"                => "friend6",
          "avatar_url"          => nil,
          "common_friend_names" => ["friend2", "friend3", "friend4", "friend5"]
        },
        {
          "id"                  => current_binding.local_variable_get(:friend7).id,
          "username"            => "friend7",
          "nickname"            => nil,
          "name"                => "friend7",
          "avatar_url"          => nil,
          "common_friend_names" => ["friend3", "friend4", "friend5"]
        },
        {
          "id"                  => current_binding.local_variable_get(:friend8).id,
          "username"            => "friend8",
          "nickname"            => nil,
          "name"                => "friend8",
          "avatar_url"          => nil,
          "common_friend_names" => ["friend4", "friend5"]
        }
      ]
    })
  end

  it 'GET show' do
    get :show, format: :json
    expect(response).to be_success
    expect(response).to render_template(:show)
    expect(json_response).to eq({
      "id"              => user.id,
      "name"            => "user",
      "username"        => "user",
      "nickname"        => nil,
      "phone_code"      => '86',
      "mobile"          => '15158166666',
      "mobile_verified" => true,
      "time_zone"       => 'Beijing',
      "state"           => 1,
      "state_string"    => user.human_state_name,
      "avatar_url"      => nil
    })
  end

  it 'PATCH update' do
    patch :update, {
      format: :json,
      nickname: 'tumayun',
      time_zone: 'Beijing',
      avatar_url: 'http://catch-avatars.qiniudn.com/sJAUYG6nc84glXkq.jpg'
    }

    expect(response).to be_success
    expect(response).to render_template(:show)
    expect(json_response[:nickname]).to eq 'tumayun'
    expect(json_response[:time_zone]).to eq 'Beijing'
    expect(json_response[:avatar_url]).to eq 'http://catch-avatars.qiniudn.com/sJAUYG6nc84glXkq.jpg'
  end

  describe 'PATCH update_mobile' do

    it 'phone_code is invalid' do
      patch :update_mobile, {
        format: :json,
        phone_code: '12345',
        mobile: '15158166372'
      }
      expect(response).to be_unprocessable
      expect(json_response[:error]).to eq subject.t('.phone_code_invalid')
    end

    it 'mobile is invalid' do
      patch :update_mobile, {
        format: :json,
        phone_code: '86',
        mobile: '15158166372111'
      }
      expect(response).to be_unprocessable
      expect(json_response[:error]).to eq subject.t('.mobile_invalid')
    end

    it 'mobile has been used' do
      create(:user, username: 'test', phone_code: '86', mobile: '15158166372')

      patch :update_mobile, {
        format: :json,
        phone_code: '86',
        mobile: '15158166372'
      }
      expect(response).to be_unprocessable
      expect(json_response[:error]).to eq subject.t('.has_been_used')
    end

    it 'update success' do
      patch :update_mobile, {
        format: :json,
        phone_code: '86',
        mobile: '15158166372'
      }
      expect(response).to be_success
      expect(subject.current_user.phone_code).to eq '86'
      expect(subject.current_user.mobile).to eq '15158166372'
      expect(subject.current_user.mobile_verified).to eq false
    end
  end
end

require 'rails_helper'

RSpec.describe Api::V4::UserController, :type => :controller do

  let(:user) { FactoryGirl.create(:user, username: 'user') }

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
      "phone_code"      => nil,
      "mobile"          => nil,
      "mobile_verified" => false,
      "time_zone"       => nil,
      "state"           => 1,
      "state_string"    => user.human_state_name,
      "avatar_url"      => nil
    })
  end

  it 'PATCH update' do
    patch :update, {
      format: :json,
      nickname: 'tumayun',
      phone_code: '86',
      mobile: '15158166372',
      time_zone: 'Beijing',
      avatar_url: 'http://catch-avatars.qiniudn.com/sJAUYG6nc84glXkq.jpg'
    }

    expect(response).to be_success
    expect(response).to render_template(:show)
    expect(json_response).to eq({
      "id"              => user.id,
      "name"            => "tumayun",
      "username"        => "user",
      "nickname"        => "tumayun",
      "phone_code"      => "86",
      "mobile"          => "15158166372",
      "mobile_verified" => false,
      "time_zone"       => "Beijing",
      "state"           => 1,
      "state_string"    => user.human_state_name,
      "avatar_url"      => "http://catch-avatars.qiniudn.com/sJAUYG6nc84glXkq.jpg"
    })
  end
end

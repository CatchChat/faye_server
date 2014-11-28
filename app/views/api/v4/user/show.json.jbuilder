json.extract! current_user, :id, :name, :username, :nickname, :phone_code, :mobile, :mobile_verified, :time_zone
json.state current_user.state
json.state_string current_user.human_state_name
json.avatar_url current_user.avatar_url

json.friends do
  json.array! @users do |user|
    json.extract! user, :id, :username, :nickname, :name
    json.avatar_url user.avatar
    json.common_friend_names user['common_friend_names'].to_s.split(',')
  end
end

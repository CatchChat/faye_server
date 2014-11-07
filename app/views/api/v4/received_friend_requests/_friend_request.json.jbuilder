user = friend_request.user
json.extract! friend_request, :id, :user_id, :friend_id, :state
json.state_string t("models.friend_request.state.#{friend_request.human_state_name}")
json.created_at format_time_to_iso8601(friend_request.created_at)
json.updated_at format_time_to_iso8601(friend_request.updated_at)
json.created_at_string format_time(friend_request.created_at)
json.updated_at_string format_time(friend_request.created_at)

json.friend do
  json.extract! user, :id, :username, :nickname
end

json.extract! friendship, :id, :user_id, :friend_id, :contact_name, :remarked_name, :position
json.created_at format_time_to_iso8601(friend_request.created_at)
json.updated_at format_time_to_iso8601(friend_request.updated_at)
json.created_at_string format_time(friend_request.created_at)
json.updated_at_string format_time(friend_request.created_at)

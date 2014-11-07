json.extract! friendship, :id, :user_id, :friend_id, :contact_name, :remarked_name, :position
json.created_at format_time_to_iso8601(friendship.created_at)
json.updated_at format_time_to_iso8601(friendship.updated_at)
json.created_at_string format_time(friendship.created_at)
json.updated_at_string format_time(friendship.created_at)

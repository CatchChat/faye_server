json.extract! group, :id, :owner_id, :name, :position
json.created_at format_time_to_iso8601(group.created_at)
json.created_at_string format_time(group.created_at)
json.updated_at format_time_to_iso8601(group.updated_at)
json.updated_at_string format_time(group.created_at)

json.friends do
  json.array! group.friendships_groups do |friendships_group|
    json.extract! friendships_group.friendship.friend, :id, :username, :nickname
    json.extract! friendships_group.friendship, :name, :contact_name, :remarked_name
    json.extract! friendships_group, :position
    json.avatar_url friendships_group.friendship.friend.avatar
  end
end

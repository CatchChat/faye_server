json.extract! message, :id, :recipient_id, :recipient_type, :text_content, :parent_id, :longitude, :latitude
json.media_type message.media_type
json.media_type_string Message.human_attribute_name(message.media_type)
json.state message.state
json.state_string message.human_state_name
json.created_at format_time_to_iso8601(message.created_at)
json.created_at_string format_time(message.created_at)
json.updated_at format_time_to_iso8601(message.updated_at)
json.updated_at_string format_time(message.created_at)

json.sender do
  json.extract! message.sender, :id, :avatar_url
  json.name message.sender.name_by_friend(current_user)
end

json.attachments do
  json.array! message.attachments do |attachment|
    attachment.file_url attachment.file
    attachment.fallback_file_url attachment.fallback_file
    attachment.extract! :storage, :fallback_storage
  end
end

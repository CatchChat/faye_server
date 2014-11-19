json.extract! message, :id, :recipient_id, :recipient_type, :media_type, :text_content, :parent_id, :state, :longitude, :latitude
json.media_type_string Message.human_attribute_name(message.media_type)
json.state_string message.human_state_name
json.created_at format_time_to_iso8601(message.created_at)
json.updated_at format_time_to_iso8601(message.updated_at)
json.created_at_string format_time(message.created_at)
json.updated_at_string format_time(message.created_at)

json.sender do
  json.extract! message.sender, :id, :avatar
  json.name message.sender.name_by_friend(current_user)
end

json.attachments do
  json.array! message.attachments do |attachment|
    attachment.extract! :storage, :file, :fallback_storage, :fallback_file
  end
end

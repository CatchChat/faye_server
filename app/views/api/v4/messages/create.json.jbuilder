json.id @message.id
json.state @message.state
json.state_string @message.human_state_name
json.media_type @message.media_type
json.media_type_string Message.human_attribute_name(@message.media_type)

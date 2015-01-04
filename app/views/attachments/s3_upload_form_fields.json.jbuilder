json.provider @provider
json.options do
  json.message_id @message.id
  json.bucket @cdn.provider.try(:bucket)
  json.key @cdn.provider.try(:key)
  json.url @url
  json.policy @policy
  json.encoded_policy @encoded_policy
  json.signature @signature
end

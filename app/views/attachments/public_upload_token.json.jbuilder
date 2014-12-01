json.provider @provider
json.options do
  json.token @token
  json.bucket @cdn.provider.try(:bucket)
  json.key @cdn.provider.try(:key)
  json.download_url @download_url
  json.file_path @cdn.provider.try(:file_path)
  json.file_length @cdn.provider.try(:file_length)
  json.callback_url @cdn.provider.try(:callback_url)
  json.callback_body @cdn.provider.try(:callback_body)
end

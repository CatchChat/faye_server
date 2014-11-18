json.messages do
  json.array! @messages, partial: 'message', as: :message
end

json.current_page @messages.current_page
json.per_page     @messages.limit_value
json.count        @messages.total_count

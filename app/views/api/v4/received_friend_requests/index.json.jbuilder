json.friend_requests do
  json.array! @friend_requests, partial: 'friend_request', as: :friend_request
end

json.current_page @friend_requests.current_page
json.per_page     @friend_requests.limit_value
json.count        @friend_requests.total_count

json.friendships do
  json.array! @friendships, partial: 'friendship', as: :friendship
end

json.current_page @friendships.current_page
json.per_page     @friendships.limit_value
json.count        @friendships.total_count

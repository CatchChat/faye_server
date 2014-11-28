json.users do
  json.array! @users, partial: 'user', as: :user
end

json.current_page @users.current_page
json.per_page     @users.limit_value
json.count        @users.total_count

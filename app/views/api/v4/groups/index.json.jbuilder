json.groups do
  json.array! @groups, partial: 'group', as: :group
end

json.current_page @groups.current_page
json.per_page     @groups.limit_value
json.count        @groups.total_count

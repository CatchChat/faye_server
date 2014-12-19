namespace :init_data do

  task user_counters: :environment do
    count = User.count
    User.find_each.with_index do |user, index|
      puts "------------#{index + 1}/#{count}-------------"
      user.unread_messages_count.value = user.unread_messages.count
      user.pending_friend_requests_count.value = user.received_friend_requests.pending.count
    end
  end
end

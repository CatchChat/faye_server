class Api::V4::UserController < ApiController

  ### GET /api/v4/user/may_know_friends
  def may_know_friends
    friend_ids = current_user.friendships.pluck(:friend_id)

    sql = <<-SQL
SELECT `users`.*, GROUP_CONCAT(IFNULL(`users_friendships`.`nickname`, `users_friendships`.`username`)) common_friend_names
FROM `users`
INNER JOIN `friendships` ON `friendships`.`friend_id` = `users`.`id`
INNER JOIN `users` `users_friendships` ON `users_friendships`.`id` = `friendships`.`user_id`
WHERE `users_friendships`.`id` IN (#{friend_ids.join(',')})
AND `users`.id NOT IN (#{(friend_ids << current_user.id).join(',')})
GROUP BY `users`.id
HAVING COUNT(`users`.id) > 1
ORDER BY COUNT(`users`.id) DESC
LIMIT 50
    SQL
    @users = User.find_by_sql(sql)
    fresh_when(@users, public: true)
  end

  ### GET /api/v4/user
  def show
  end

  ### PATCH /api/v4/user
  # Optional params
  #   nickname
  #   mobile
  #   phone_code
  #   time_zone
  #   avatar_url
  def update
    if current_user.update(update_params)
      render :show
    else
      render json: { error: current_user.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.permit(:nickname, :mobile, :phone_code, :time_zone, :avatar_url)
  end
end

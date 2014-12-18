class Api::V4::UserController < ApiController

  ### GET /api/v4/user/may_know_friends
  def may_know_friends
    friend_ids = current_user.friendships.pluck(:friend_id)

    if friend_ids.blank?
      @users = User.none
    else
      official_accounts_ids = User.where(username: Settings.official_accounts).pluck(:id)
      @users = User.find_by_sql <<-SQL
SELECT `users`.*, GROUP_CONCAT(IFNULL(`users_friendships`.`nickname`, `users_friendships`.`username`)) common_friend_names
FROM `users`
INNER JOIN `friendships` ON `friendships`.`friend_id` = `users`.`id`
INNER JOIN `users` `users_friendships` ON `users_friendships`.`id` = `friendships`.`user_id`
WHERE `users_friendships`.`id` IN (#{(friend_ids - official_accounts_ids).join(',')})
AND `users`.id NOT IN (#{(friend_ids + [current_user.id] + official_accounts_ids).join(',')})
GROUP BY `users`.id
HAVING COUNT(`users`.id) > 1
ORDER BY COUNT(`users`.id) DESC
LIMIT 50
      SQL
    end

    fresh_when(@users, public: true)
  end

  ### GET /api/v4/user
  def show
  end

  ### PATCH /api/v4/user
  # Optional params
  #   nickname
  #   avatar_url
  def update
    if current_user.update(update_params)
      render :show
    else
      render json: { error: current_user.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### PATCH /api/v4/user/update_mobile
  # Required params
  #   mobile
  #   phone_code
  #   token
  def update_mobile
    unless SmsVerificationCode.verify_token(mobile: params[:mobile], phone_code: params[:phone_code], token: params[:token])
      return render json: { error: t('.invalid_token') }, status: :unprocessable_entity
    end

    if User.where(phone_code: params[:phone_code], mobile: params[:mobile]).where.not(id: current_user.id).count > 0
      return render json: { error: t('.has_been_used') }, status: :unprocessable_entity
    end

    current_user.phone_code = params[:phone_code]
    current_user.mobile     = params[:mobile]
    current_user.mobile_verified = true

    if current_user.save
      render json: { phone_code: current_user.phone_code, mobile: current_user.mobile, mobile_verified: current_user.mobile_verified }
    else
      render json: { error: current_user.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.permit(:nickname, :avatar_url)
  end
end

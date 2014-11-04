class Api::V4::FriendRequestsController < ApiController
  before_action :load_friend_request, only: %i(show destroy accept reject block)

  ### POST api/v4/friend_requests
  # params
  #   friend_id
  def create
    friend = User.find_by(id: params[:friend_id])
    return render json: { error: t('.not_found') }, status: :not_found unless friend

    if current_user.friends.find_by(id: friend.id)
      return render json: { error: t('.already_friend', friend_name: friend.name) }, status: :forbidden
    end

    if current_user.friend_requests.blocked.find_by(friend_id: friend.id)
      return render json: { error: t('.blocked', friend_name: friend.name) }, status: :forbidden
    end

    friend_request = current_user.friend_requests.new(friend_id: friend.id)
    if friend_request.save
      render json: format_json(friend_request)
    else
      render json: { error: friend_request.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/accept
  def accept
    if @friend_request.accept
      render json: format_json(@friend_request)
    else
      render json: { error: t('.accept_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/reject
  def reject
    if @friend_request.reject
      render json: format_json(@friend_request)
    else
      render json: { error: t('.reject_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/block
  def block
    if @friend_request.block
      render json: format_json(@friend_request)
    else
      render json: { error: t('.block_error') }, status: :unprocessable_entity
    end
  end

  ### GET api/v4/friend_requests/:id
  def show
    render json: format_json(@friend_request)
  end

  ### DELETE api/v4/friend_requests/:id
  def destroy
    @friend_request.destroy
    render json: format_json(@friend_request)
  end

  private

  def load_friend_request
    unless @friend_request = current_user.friend_requests.find_by(id: params[:id])
      return render json: { error: t('.not_found') }, status: :not_found
    end
  end

  def format_json(friend_request)
    json = friend_request.attributes.except(:created_at, :updated_at)
    json.merge(
      created_at: format_time_to_iso8601(friend_request.created_at),
      updated_at: format_time_to_iso8601(friend_request.updated_at),
      created_at_string: format_time(friend_request.created_at),
      updated_at_string: format_time(friend_request.created_at),
      state_string: t("models.friend_request.state.#{friend_request.human_state_name}")
    )
  end
end

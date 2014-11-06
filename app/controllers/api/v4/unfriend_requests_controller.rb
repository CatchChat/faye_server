class Api::V4::UnfriendRequestsController < ApiController

  ### POST /api/v4/unfriend_requests
  # Required params
  #   friend_id
  def create
    friend = current_user.friends.find_by(id: params[:friend_id])
    return render json: { error: t('.not_found') }, status: :not_found unless friend

    unfriend_request = current_user.unfriend_requests.build(friend_id: friend.id)
    if unfriend_request.save
      render json: {}
    else
      render json: { error: unfriend_request.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end
end

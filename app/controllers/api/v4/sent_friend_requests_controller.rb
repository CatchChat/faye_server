class Api::V4::SentFriendRequestsController < ApiController
  before_action :load_friend_request, only: %i(destroy)

  ### GET api/v4/friend_requests/sent
  # Optional params
  #   per_page
  #   page
  #   sort
  #   direction
  #   state Only ['pending', 'accepted', 'rejected', 'blocked']
  def index
    order_string = "#{FriendRequest.table_name}.#{sort_column(FriendRequest)} #{sort_direction}"
    @friend_requests = current_user.sent_friend_requests.includes(:friend).order(order_string)
    @friend_requests = @friend_requests.with_state(params[:state]) if params[:state].present?
    @friend_requests = @friend_requests.page(params[:page]).per(params[:per_page])
    fresh_when(@friend_requests, public: true)
  end

  ### POST api/v4/friend_requests
  # Required params
  #   friend_id
  def create
    friend = User.find_by(id: params[:friend_id])
    return render json: { error: t('.not_found') }, status: :not_found unless friend

    if current_user.friends.find_by(id: friend.id)
      return render json: { error: t('.already_friend', friend_name: friend.name) }, status: :forbidden
    end

    if current_user.sent_friend_requests.blocked.find_by(friend_id: friend.id)
      return render json: { error: t('.blocked', friend_name: friend.name) }, status: :forbidden
    end

    @friend_request = current_user.sent_friend_requests.new(friend_id: friend.id)
    if @friend_request.save
      Pusher.push_to_user(friend.id, content: t('notification.wants_to_be_friend', friend_name: current_user.name))
      render :show
    else
      render json: { error: @friend_request.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### DELETE api/v4/friend_requests/sent/:id
  def destroy
    @friend_request.destroy
    render json: {}
  end

  private

  def load_friend_request
    unless @friend_request = current_user.sent_friend_requests.find_by(id: params[:id])
      return render json: { error: t('.not_found') }, status: :not_found
    end
  end
end

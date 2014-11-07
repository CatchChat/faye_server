class Api::V4::ReceivedFriendRequestsController < ApiController
  before_action :load_friend_request, only: %i(destroy accept reject block)

  ### GET api/v4/friend_requests
  # Optional params
  #   per_page
  #   page
  #   sort
  #   direction
  #   state
  def index
    order_string = "#{FriendRequest.table_name}.#{sort_column(FriendRequest)} #{sort_direction}"
    @friend_requests = current_user.received_friend_requests.includes(:user).order(order_string)
    @friend_requests = @friend_requests.by_state(params[:state]) if params[:state].present?
    @friend_requests = @friend_requests.page(normalize_page).per(normalize_per_page)
  end

  ### PATCH api/v4/friend_requests/:id/accept
  def accept
    if @friend_request.accept
      # TODO Push message to user
      render :show
    else
      render json: { error: t('.accept_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/reject
  def reject
    if @friend_request.reject
      # TODO Push message to user
      render :show
    else
      render json: { error: t('.reject_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/block
  def block
    if @friend_request.block
      # TODO Push message to user
      render :show
    else
      render json: { error: t('.block_error') }, status: :unprocessable_entity
    end
  end

  ### DELETE api/v4/friend_requests/:id
  def destroy
    @friend_request.destroy
    render :show
  end

  private

  def load_friend_request
    unless @friend_request = current_user.received_friend_requests.find_by(id: params[:id])
      return render json: { error: t('.not_found') }, status: :not_found
    end
  end
end

class Api::V4::ReceivedFriendRequestsController < ApiController
  before_action :load_friend_request, only: %i(destroy accept reject block)

  ### GET api/v4/friend_request/received
  # Optional params
  #   per_page
  #   page
  #   sort
  #   direction
  #   state Only ['pending', 'accepted', 'rejected', 'blocked']
  def index
    order_string = "#{FriendRequest.table_name}.#{sort_column(FriendRequest)} #{sort_direction}"
    @friend_requests = current_user.received_friend_requests.includes(:user).order(order_string)
    @friend_requests = @friend_requests.with_state(params[:state]) if params[:state].present?
    @friend_requests = @friend_requests.page(params[:page]).per(params[:per_page])
    fresh_when(@friend_requests, public: true)
  end

  ### PATCH api/v4/friend_requests/received/:id/accept
  def accept
    if @friend_request.accept
      PushNotificationToUserJob.perform_async(
        @friend_request.user_id,
        content: t(
          'notification.accepted_friend_request',
          friend_name: current_user.name_by_friend(@friend_request.user)
        ),
        extras: { type: 'friend_request', subtype: @friend_request.state_name }
      )
      render :show
    else
      render json: { error: t('.accept_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/received/:id/reject
  def reject
    if @friend_request.reject
      PushNotificationToUserJob.perform_async(
        @friend_request.user_id,
        content: t(
          'notification.rejected_friend_request',
          friend_name: current_user.name_by_friend(@friend_request.user)
        ),
        extras: { type: 'friend_request', subtype: @friend_request.state_name }
      )
      render :show
    else
      render json: { error: t('.reject_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/received/:id/block
  def block
    if @friend_request.block
      PushNotificationToUserJob.perform_async(
        @friend_request.user_id,
        content: t(
          'notification.blocked_friend_request',
          friend_name: current_user.name_by_friend(@friend_request.user)
        ),
        extras: { type: 'friend_request', subtype: @friend_request.state_name }
      )
      render :show
    else
      render json: { error: t('.block_error') }, status: :unprocessable_entity
    end
  end

  ### DELETE api/v4/friend_requests/received/:id
  def destroy
    @friend_request.destroy
    render json: {}
  end

  private

  def load_friend_request
    unless @friend_request = current_user.received_friend_requests.find_by(id: params[:id])
      return render json: { error: t('.not_found') }, status: :not_found
    end
  end
end

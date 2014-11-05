class Api::V4::FriendRequestsController < ApiController
  before_action :load_friend_request, only: %i(show destroy accept reject block)

  ### GET api/v4/friend_requests
  # params
  #   per_page
  #   page
  #   sort
  #   direction
  def index
    params[:page]     ||= 1
    params[:per_page] ||= 10
    order_string = "#{FriendRequest.table_name}.#{sort_column} #{sort_direction}"
    @friend_requests = current_user.friend_requests.includes(:user, :friend).order(order_string)
    @friend_requests = @friend_requests.page(params[:page]).per(params[:per_page])
  end

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

    @friend_request = current_user.friend_requests.new(friend_id: friend.id)
    if @friend_request.save
      render :show
    else
      render json: { error: @friend_request.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/accept
  def accept
    if @friend_request.accept
      render :show
    else
      render json: { error: t('.accept_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/reject
  def reject
    if @friend_request.reject
      render :show
    else
      render json: { error: t('.reject_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH api/v4/friend_requests/:id/block
  def block
    if @friend_request.block
      render :show
    else
      render json: { error: t('.block_error') }, status: :unprocessable_entity
    end
  end

  ### GET api/v4/friend_requests/:id
  def show
  end

  ### DELETE api/v4/friend_requests/:id
  def destroy
    @friend_request.destroy
    render :show
  end

  private

  def load_friend_request
    unless @friend_request = current_user.friend_requests.find_by(id: params[:id])
      return render json: { error: t('.not_found') }, status: :not_found
    end
  end

  def sort_column
    FriendRequest.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end

  def sort_direction
    direction = params[:direction].to_s.upcase
    %w(ASC DESC).include?(direction) ? direction : "DESC"
  end
end

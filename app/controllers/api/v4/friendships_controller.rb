class Api::V4::FriendshipsController < ApiController
  before_action :load_friendship, only: %i(show update move_to_top)

  ### GET /api/v4/friendships
  # Optional params
  #   page
  #   per_page
  def index
    @friendships = current_user.friendships.includes(:friend)
    @friendships = @friendships.page(params[:page]).per(params[:per_page])
    fresh_when(@friendships, public: true)
  end

  ### GET /api/v4/friendships/recent
  # Optional params
  #   page
  #   per_page
  def recent
    where_sql = <<-SQL
friendships.friend_id IN (
  SELECT messages.recipient_id friend_id FROM messages
  WHERE messages.sender_id = :current_user_id AND messages.recipient_type = 'User'
  AND messages.created_at >= :time
  UNION
  SELECT messages.sender_id friend_id FROM messages
  WHERE messages.recipient_id = :current_user_id AND messages.recipient_type = 'User'
  AND messages.created_at >= :time
)
    SQL

    @friendships = current_user.friendships.includes(:friend).where(
      where_sql,
      current_user_id: current_user.id,
      time: 3.days.ago
    ).page(params[:page]).per(params[:per_page])
    render :index if stale?(@friendships, public: true)
  end

  ### GET /api/v4/friendships/search
  # Required params
  #   q
  # Optional params
  #   page
  #   per_page
  def search
    if params[:q].present?
      @friendships = current_user.friendships.includes(:friend).references(:friend).where(search_conditions)
    else
      @friendships = Friendship.none
    end

    @friendships = @friendships.page(params[:page]).per(params[:per_page])
    render :index if stale?(@friendships, public: true)
  end

  ### GET /api/v4/friendships/:id
  def show
    fresh_when(@friendship, public: true)
  end

  ### PUT /api/v4/friendships/:id
  # Optional params
  #   remarked_name
  #   contact_name
  def update
    unless @friendship.update(friendship_params)
      render json: { error: @friendship.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### PATCH /api/v4/friendships/:id/move_to_top
  def move_to_top
    if @friendship.move_to_top
      render json: {}
    else
      render json: { error: t('.move_to_top_error') }, status: :unprocessable_entity
    end
  end

  ### GET /api/v4/friendships/with/:friend_id
  def by_friend
    @friendship = current_user.friendships.find_by(friend_id: params[:friend_id])
    return render json: { error: t('.not_found') }, status: :not_found unless @friendship

    render :show if stale?(@friendship, public: true)
  end

  private

  def load_friendship
    @friendship = current_user.friendships.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless @friendship
  end

  def friendship_params
    params.permit(:remarked_name, :contact_name)
  end

  def search_conditions
    conditions = [[]]
    conditions[0] << "friendships.remarked_name LIKE :keyword"
    conditions[0] << "friendships.contact_name LIKE :keyword"
    conditions[0] << "users.nickname LIKE :keyword"
    conditions[0] << "users.username LIKE :keyword"
    conditions << { keyword: "%#{params[:q]}%" }
    conditions[0] = conditions[0].join(' OR ')
    conditions
  end
end

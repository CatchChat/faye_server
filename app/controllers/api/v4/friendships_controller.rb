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
    joins_sql = <<-SQL
INNER JOIN messages sent_messages
ON sent_messages.sender_id = friendships.user_id
INNER JOIN messages received_messages
ON received_messages.recipient_id = friendships.user_id AND received_messages.recipient_type = 'User'
    SQL

    @friendships = current_user.friendships.joins(joins_sql).includes(:friend).where(
      'sent_messages.created_at >= :time OR received_messages.created_at >= :time',
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
    @friendships = current_user.friendships.includes(:friend)
    @friendships = @friendships.where('contact_name LIKE :keyword OR remarked_name LIKE :keyword', keyword: "%#{params[:q]}%")
    @friendships = @friendships.page(params[:page]).per(params[:per_page])
    render :index if stale?(@friendships, public: true)
  end

  ### GET /api/v4/friendships/:id
  def show
    fresh_when(@friendship, public: true)
  end

  ### PUT /api/v4/friendships/:id
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

  private

  def load_friendship
    @friendship = current_user.friendships.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless @friendship
  end

  def friendship_params
    params.permit(:remarked_name, :contact_name)
  end
end

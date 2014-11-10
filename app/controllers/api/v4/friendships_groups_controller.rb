class Api::V4::FriendshipsGroupsController < ApiController
  before_action :load_group

  ### GET /api/v4/groups/:group_id/friends
  # Optional params
  #   page
  #   per_page
  def index
    @friendships = @group.friendships.includes(:friends)
    @friendships = @friendships.page(params[:page]).per(params[:per_page])
    fresh_when([@group, @group.friendships, @group.friends], public: true)
  end

  ### POST /api/v4/groups/:group_id/friends
  # Required params
  #   friend_id
  def create
    unless friendship = current_user.friendships.find_by(friend_id: params[:friend_id])
      return render json: { error: t('.not_friend') }, status: :not_found
    end

    friendships_group = @group.friendships_groups.build(friendship_id: friendship.id)
    unless friendships_group.save
      render json: { error: friendships_group.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### DELETE /api/v4/groups/:group_id/friends/:id
  def destroy
    unless friendships_group = @group.friendships_groups.joins(:friendship).
      find_by(Friendship.table_name => { friend_id: params[:id] })
      return render json: { error: t('.not_in_group') }, status: :not_found
    end

    friendships_group.destroy
    render json: {}
  end

  private

  def load_group
    unless @group = current_user.groups.find_by(id: params[:group_id])
      return render json: { error: t('.group_not_found') }, status: :not_found
    end
  end
end

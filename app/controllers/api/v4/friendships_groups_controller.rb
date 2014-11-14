class Api::V4::FriendshipsGroupsController < ApiController
  before_action :load_group, only: %i(create destroy)

  ### POST /api/v4/groups/:group_id/add_friendship/:friendship_id
  def create
    unless friendship = current_user.friendships.find_by(id: params[:friendship_id])
      return render json: { error: t('.not_friend') }, status: :not_found
    end

    friendships_group = @group.friendships_groups.build(friendship_id: friendship.id)
    unless friendships_group.save
      render json: { error: friendships_group.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### DELETE /api/v4/groups/:group_id/remove_friendship/:friendship_id
  def destroy
    unless friendships_group = @group.friendships_groups.find_by(friendship_id: params[:friendship_id])
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

class Api::V4::GroupsController < ApiController
  before_action :load_group, only: [:show, :update, :destroy]

  ### GET /api/v4/groups
  # Optional params
  #   page
  #   per_page
  def index
    @groups = current_user.groups.includes(:friends)
    @groups = @groups.page(params[:page]).per(params[:per_page])
    fresh_when([@groups, @groups.map(&:friendships), @groups.map(&:friends)], public: true)
  end

  ### POST /api/v4/groups
  # Required params
  #   name
  def create
    @group = current_user.groups.create(group_params)

    unless @group.persisted?
      render json: { error: @group.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### PUT /api/v4/groups/:id
  # Optional params
  #   name
  def update
    unless @group.update(group_params)
      render json: { error: @group.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### GET /api/v4/groups/:id
  def show
    fresh_when([@group, @group.friendships_groups, @group.friendships, @group.friends], public: true)
  end

  ### DELETE /api/v4/groups/:id
  def destroy
    @group.destroy
    render json: {}
  end

  private

  def group_params
    params.permit(:name)
  end

  def load_group
    unless @group = current_user.groups.find_by(id: params[:id])
      return render json: { error: t('.not_found') }, status: :not_found
    end
  end
end

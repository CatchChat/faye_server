class Api::V4::UsersController < ApiController
  skip_before_action :authenticate_user, only: %i(username_validate)

  ### GET api/v4/users/search
  # Required params
  #   q       :doc: q can be username or nickname
  #   page
  #   per_page
  def search
    if params[:q].present?
      @users = User.active.where('username = :keyword OR nickname = :keyword', { keyword: params[:q] })
    else
      @users = User.none
    end

    @users = @users.page(params[:page]).per(params[:per_page])
    render :search if stale?(@users, public: true)
  end

  ### GET api/v4/users/username_validate
  # Required params
  #   username
  def username_validate
    username = params[:username].to_s
    if username.length < 4 || username.length > 16 || username !~ /\A[a-zA-Z0-9]+\z/
      return render json: { available: false, message: t('.username_invalid') }
    end

    if User.where(username: username).count > 0
      return render json: { available: false, message: t('.has_been_used') }
    end

    render json: { available: true }
  end
end

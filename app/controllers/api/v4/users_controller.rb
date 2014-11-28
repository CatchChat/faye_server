class Api::V4::UsersController < ApiController

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
end

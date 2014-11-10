class Api::V4::FriendshipsController < ApiController

  ### GET /api/v4/friends
  # Optional params
  #   page
  #   per_page
  def index
    @friendships = current_user.friendships.includes(:friend)
    @friendships = @friendships.page(params[:page]).per(params[:per_page])
    fresh_when(@friendships, public: true)
  end
end

class Api::V4::FriendshipsController < ApiController

  ### GET /api/v4/friendships
  # Optional params
  #   page
  #   per_page
  def index
    @friendships = current_user.friendships
    @friendships = @friendships.page(normalize_page).per(normalize_per_page)
  end
end

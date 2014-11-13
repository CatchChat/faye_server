class Api::V4::MessagesController < ApiController

  ### GET /api/v4/messages/unread
  # Optional params
  #   page
  #   per_page
  def unread
    @unread_messages = current_user.unread_messages.order("#{Message.table_name}.id DESC")
    @unread_messages = @unread_messages.page(params[:page]).per(params[:per_page])
    fresh_when(@unread_messages, public: true)
  end

  ### POST /api/v4/messages
  # Required params
  #   recipient_id
  #   text_content
  # Optional params
  #   parent_id
  #   file
  #   storage
  def create
    
  end

  ### PATCH /api/v4/messages/:id/mark_as_read
  def mark_as_read
    @message = current.unread_messages.find_by(id: params[:id])
    render json: { error: t('.not_found') }, status: :not_found unless @message

    if @message.mark_as_read
      render json: {}
    else
      render json: { error: @message.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end
end

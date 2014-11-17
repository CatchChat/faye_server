class Api::V4::MessagesController < ApiController

  ### GET /api/v4/messages/unread
  # Optional params
  #   page
  #   per_page
  def unread
    @messages = current_user.unread_messages
    @messages = @messages.page(params[:page]).per(params[:per_page])
    fresh_when(@messages, public: true)
  end

  ### POST /api/v4/messages
  # Required params
  #   recipient_id
  # Optional params
  #   text_content
  #   parent_id
  #   attachment_file
  #   attachment_storage
  #   longitude
  #   latitude
  def create
    recipient = current_user.friends.find_by(id: params[:recipient_id])
    return render json: { error: t('.not_found_recipient') } unless recipient

    message = current_user.sent_messages.new(create_params)
    message.recipient = recipient

    if message.save
      Pusher.push_to_user(recipient, content: t(
        '.sent_message_to_you',
        friend_name: current_user.name,
        media_type: Message.human_attribute_name(message.media_type)
      ))
      render json: {}
    else
      render json: { error: message.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### PATCH /api/v4/messages/:id/mark_as_read
  def mark_as_read
    message = current_user.unread_messages.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless message

    if message.mark_as_read
      render json: {}
    else
      render json: { error: t('.mark_as_read_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH /api/v4/messages/:id/deliver
  def deliver
    message = current_user.unread_messages.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless message

    if message.individual_recipients.first.deliver
      render json: {}
    else
      render json: { error: t('.deliver_error') }, status: :unprocessable_entity
    end
  end

  ### GET /api/v4/messages/:id
  def show
    message = current_user.received_messages.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless message
    fresh_when(message, public: true)
  end

  private

  def create_params
    params.permit(:text_content, :parent_id, :attachment_file, :attachment_storage, :longitude, :latitude)
  end
end

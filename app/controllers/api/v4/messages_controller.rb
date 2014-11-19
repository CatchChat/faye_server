class Api::V4::MessagesController < ApiController

  ### GET /api/v4/messages/unread
  # Optional params
  #   page
  #   per_page
  def unread
    @messages = current_user.unread_messages.includes(:attachments)
    @messages = @messages.page(params[:page]).per(params[:per_page])
    fresh_when(@messages, public: true)
  end

  ### POST /api/v4/messages
  # Required params
  #   recipient_id
  #   recipient_type  Only User or Group
  #   media_type      0 is text, 1 is photo, 2 is video, default is text
  # Optional params
  #   text_content
  #   parent_id
  #   longitude
  #   latitude
  def create
    recipient = find_recipient
    return render json: { error: t('.not_found_recipient') }, status: :not_found unless recipient

    media_type = params[:media_type].to_i
    media_type = Message.media_types[:text] unless Message.media_types.values.include? media_type
    message = current_user.sent_messages.new(create_params)
    message.media_type = media_type
    message.recipient  = recipient

    result = false
    if message.save
      result = true
      result = message.mark_as_unread if message.text?
    end

    if result
      Pusher.push_to_users(message.individual_recipients.map(&:user_id), content: t(
        '.sent_message_to_you',
        friend_name: current_user.name,
        media_type: Message.human_attribute_name(message.media_type)
      )) if message.unread?
      render json: {}
    else
      render json: { error: message.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  ### PATCH /api/v4/messages/:id/mark_as_read
  def mark_as_read
    message = current_user.received_messages.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless message

    individual_recipient = message.individual_recipients.find_by(user_id: current_user.id)
    if individual_recipient.read? || individual_recipient.mark_as_read
      render json: {}
    else
      render json: { error: t('.mark_as_read_error') }, status: :unprocessable_entity
    end
  end

  ### PATCH /api/v4/messages/:id/deliver
  def deliver
    message = current_user.received_messages.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless message

    individual_recipient = message.individual_recipients.find_by(user_id: current_user.id)
    if individual_recipient.delivered? || individual_recipient.read? || individual_recipient.deliver
      render json: {}
    else
      render json: { error: t('.deliver_error') }, status: :unprocessable_entity
    end
  end

  ### GET /api/v4/messages/:id
  def show
    @message = current_user.received_messages.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless @message
    fresh_when(@message, public: true)
  end

  private

  def find_recipient
    case params[:recipient_type]
    when 'User'
      current_user.friends.find_by(id: params[:recipient_id])
    when 'Group'
      current_user.groups.find_by(id: params[:recipient_id])
    end
  end

  def create_params
    params.permit(:text_content, :parent_id, :longitude, :latitude)
  end
end
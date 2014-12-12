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
  #   battery_level   0 - 100
  # Optional params
  #   media_type      0 is text, 1 is photo, 2 is video, default is text
  #   text_content
  #   parent_id
  #   longitude
  #   latitude
  def create
    recipient = find_recipient
    return render json: { error: t('.not_found_recipient') }, status: :not_found unless recipient

    media_type = params[:media_type].to_i
    media_type = Message.media_types[:text] unless Message.media_types.values.include? media_type
    battery_level = (params[:battery_level].presence || 50).to_i
    battery_level = 0 if battery_level < 0
    battery_level = 100 if battery_level > 100
    @message = current_user.messages.new(create_params)
    @message.media_type = media_type
    @message.recipient  = recipient
    @message.battery_level = battery_level

    result = false
    if @message.save
      result = true
      result = @message.mark_as_unread if @message.text?
    end

    if result
      if recipient.is_a?(User) && recipient.official_account?
        SendOfficialMessageJob.perform_async(recipient.id, current_user.id, @message.id)
      end
      MessageNotificationJob.perform_async(@message.id) if @message.unread?
    else
      render json: { error: @message.errors.full_messages.join("\n") }, status: :unprocessable_entity
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
      friendship = current_user.friendships.find_by(friend_id: message.sender_id)
      friendship.move_to_top if friendship
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

  ### POST /api/v4/messages/:id/report
  def report
    message = current_user.received_messages.find_by(id: params[:id])
    return render json: { error: t('.not_found') }, status: :not_found unless message

    report = current_user.report_message(message)
    if report.errors.empty?
      render json: {}
    else
      render json: { error: report.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
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

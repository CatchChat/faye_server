class Api::V4::ReportsController < ApiController

  ### POST /api/v4/reports
  # Required params
  #   message_id
  def create
    message = current_user.received_messages.find_by(id: params[:message_id])
    return render json: { error: t('.message_not_found') }, status: :not_found unless message

    report = current_user.report_message(message)
    if report.errors.empty?
      render json: {}
    else
      render json: { error: report.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end
end

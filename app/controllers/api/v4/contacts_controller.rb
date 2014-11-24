class Api::V4::ContactsController < ApiController

  ### POST /api/v4/contacts/upload
  # ** Upload overlay **
  # Required params
  #   contacts JSON format
  # Example
  #   contacts: "[{\"name\":\"abc\",\"number\":\"15158166372\"},{\"name\":\"bac\",\"number\":\"15158166723\"}]"
  def upload
    contacts = []
    JSON.parse(params[:contacts]).each do |contact|
      contacts << Contact.new(contact.merge(user_id: current_user.id))
    end
    current_user.contacts = contacts
    current_user.save
    render json: {}
  rescue => ex
    logger.debug "===> #{ex}\n#{ex.backtrace.join("\n")}"
    return render json: { error: t('.contacts_error') }, status: :unprocessable_entity
  end
end

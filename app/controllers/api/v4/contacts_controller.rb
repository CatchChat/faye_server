class Api::V4::ContactsController < ApiController

  ### POST /api/v4/contacts/upload
  # ** Upload overlay **
  # Required params
  #   contacts JSON format
  # Example
  #   contacts: "[{\"name\":\"abc\",\"number\":\"15158166372\"},{\"name\":\"bac\",\"number\":\"15158166723\"}]"
  def upload
    contacts, country_code_and_numbers = [], []
    JSON.parse(params[:contacts]).each do |contact|
      country_code, pure_number = Contact.parse_number(contact['number'])
      country_code = Contact::COUNTRY_CODES['China'] if country_code.blank?
      country_code_and_numbers << [country_code, pure_number]
      contacts << Contact.new(contact.merge(user_id: current_user.id))
    end

    current_user.contacts = contacts
    current_user.save!

    render json: { registered_contacas: calculate_registered_contacas(country_code_and_numbers) }
  rescue => ex
    logger.debug "===> #{ex}\n#{ex.backtrace.join("\n")}"
    return render json: { error: t('.contacts_error') }, status: :unprocessable_entity
  end

  private

  def calculate_registered_contacas(country_code_and_numbers)
    encrypted_numbers_hash = {}

    conditions = [[]]
    country_code_and_numbers.each do |(country_code, pure_number)|
      conditions[0] << "(users.mobile = ? AND users.phone_code = ?)"
      conditions << pure_number << country_code
    end
    conditions[0] = conditions[0].join(' OR ')

    User.mobile_verified.where(conditions).each do |user|
      encrypted_numbers_hash[Contact.encrypt_number("+#{user.phone_code}#{user.mobile}")] = user.id
    end

    contacts = current_user.contacts.where(encrypted_number: encrypted_numbers_hash.keys)
    contacts.inject([]) do |result, contact|
      result << { name: contact.name, user_id: encrypted_numbers_hash[contact.encrypted_number] }
    end
  end
end

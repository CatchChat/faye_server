module ResponseHelper

  def json_response
    case body = JSON.parse(response.body)
    when Hash
      body.with_indifferent_access
    when Array
      body
    end
  end
end

RSpec.configure do |config|
  config.include ResponseHelper, type: :controller
end

require_relative '../rails_helper'
require_relative '../spec_helper'
require_relative '../../lib/auth_token'

describe AuthToken do

  before do
    user = create :user
    @client = double()
    @client.extend AuthToken
    allow(@client). to receive(:request) {
      OpenStruct.new headers: {
        'X-CatchChatToken' => Base64.encode64(user.access_token.token),
        'X-CatchChatAuth'  => 'cnVhbnd6dGVzdDpydWFud3p0ZXN0' }
    }
  end


  it "check_access_token" do
    expect(@client.check_access_token).to eq true
  end

  it "check_username_password" do
    expect(@client.check_username_password).to eq true
  end

end

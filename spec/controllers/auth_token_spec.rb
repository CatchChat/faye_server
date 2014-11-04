require_relative '../rails_helper'
require_relative '../spec_helper'

describe AuthToken do

  before do
    user = create :user
    @client = double()
    @client.extend AuthToken
    # following token just contains uniq token
    allow(@client). to receive(:request) {
      OpenStruct.new headers: {
        'X-CatchChatToken' => Base64.encode64(user.access_token.token),
        'X-CatchChatAuth'  => Base64.encode64('ruanwztest:ruanwztest') }
    }
  end


  it "check_access_token" do
    expect(@client.check_access_token).to eq true
  end

  it "check_username_password" do
    expect(@client.check_username_password).to eq true
  end

end

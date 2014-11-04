require_relative '../rails_helper'
require_relative '../spec_helper'
require_relative '../../lib/auth_token'

describe AuthToken do
  module AuthToken
    def self.request
    end
  end

  before do
    user = create :user
    # following token just contains uniq token
    allow(AuthToken).to receive(:request) {
      OpenStruct.new headers: {
        'X-CatchChatToken' => Base64.encode64(user.access_token.token),
        'X-CatchChatAuth'  => Base64.encode64('ruanwztest:ruanwztest') }
    }
  end


  it "check_access_token" do
    expect(AuthToken.check_access_token).to eq true
  end

  it "check_username_password" do
    expect(AuthToken.check_username_password).to eq true
  end

end

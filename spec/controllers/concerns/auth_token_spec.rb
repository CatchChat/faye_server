require_relative '../../rails_helper'

describe AuthToken do
  module AuthToken
    def self.request
    end
  end

  before do
    user = create :user
    # following token just contains uniq token
  end


  it "check_access_token" do
    request = OpenStruct.new headers: {'AuthorizationToken' =>'test-token' }
    expect(AuthToken.check_access_token(request)).to be_an_instance_of User
  end

  it "check_username_password" do
    expect(AuthToken.check_username_password('ruanwztest','ruanwztest')).to be_an_instance_of User
  end

end

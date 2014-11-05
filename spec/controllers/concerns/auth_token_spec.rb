require_relative '../../rails_helper'

describe AuthToken do
  module AuthToken
    def self.request
    end
  end

  before do
    @user = create :user
    @mobile_user = create :mobile_user
    # following token just contains uniq token
  end


  it "check_access_token" do
    request = OpenStruct.new headers: {'AuthorizationToken' =>'test-token' }
    expect(AuthToken.check_access_token(request)).to be_an_instance_of User
  end

  it "check_username_password" do
    expect(AuthToken.check_username_password('ruanwztest','ruanwztest')).to be_an_instance_of User
  end

  it "check_mobile_and_sms_verification_code" do
    expect(AuthToken.check_mobile_and_sms_verification_code(@mobile_user.mobile, @mobile_user.sms_verification_code.token)).to be_an_instance_of User
  end

end
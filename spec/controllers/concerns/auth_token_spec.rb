require_relative '../../rails_helper'

describe AuthToken do
  module AuthToken
    def self.request
    end
  end

  before do
    @user = create :user, mobile: '1234567'
    # following token just contains uniq token
  end


  it "check_access_token and save to AccessToken.current" do
    request = OpenStruct.new headers: {'AuthorizationToken' =>'test-token' }
    expect(AuthToken.check_access_token(request)).to be_an_instance_of User
    expect(AccessToken.current).to eq @user.access_tokens.last
  end

  it "check_access_token and raise exception if expired" do
    request = OpenStruct.new headers: {'AuthorizationToken' =>'test-token' }
    Timecop.freeze(Time.local(2015))
    expect {AuthToken.check_access_token(request)}.to raise_error AuthToken::Exceptions::TokenExpired
    Timecop.return
  end
  it "check_password" do
    expect(AuthToken.check_password('ruanwztest','ruanwztest')).to be_an_instance_of User
    expect(AuthToken.check_password('1234567','ruanwztest')).to be_an_instance_of User
  end

  it "check_mobile_and_sms_verification_code" do
    expect(AuthToken.check_mobile_and_sms_verification_code(@user.mobile, @user.sms_verification_codes.last.token)).to be_an_instance_of User
  end

end

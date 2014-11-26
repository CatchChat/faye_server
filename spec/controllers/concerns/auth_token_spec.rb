require_relative '../../rails_helper'

describe AuthToken do
  module AuthToken
    def self.request
    end
  end

  let(:request) {double}

  before do
    allow(request).to receive(:headers) { {'Authorization' =>'Token token="test-token"' } }
    @user = create :user, mobile: '1234567', email: 'a@b.c'
    # following token just contains uniq token
  end


  it "check_access_token and save to AccessToken.current" do
    expect(AuthToken.check_access_token(request)).to be_an_instance_of User
    expect(AccessToken.current).to eq @user.access_tokens.last
  end

  it "check_access_token and raise exception if header format error" do
    allow(request).to receive(:headers) { {'Authorization' =>'Token privatetoken="test-token"' } }
    expect {AuthToken.check_access_token(request)}.to raise_error AuthToken::Exceptions::TokenNotFound
  end

  it "check_access_token and raise exception if expired" do
    Timecop.freeze(Time.local(2015))
    expect {AuthToken.check_access_token(request)}.to raise_error AuthToken::Exceptions::TokenExpired
    Timecop.return
  end
  it "check_password" do
    user = AuthToken.check_password('ruanwztest','ruanwztest')
    expect(user).to be_an_instance_of User
    expect(AuthToken.check_password('1234567','ruanwztest')).to be_an_instance_of User
    expect(AuthToken.check_password('a@b.c','ruanwztest')).to be_an_instance_of User
  end

  it "check_mobile_and_sms_verification_code" do
    user = AuthToken.check_mobile_and_sms_verification_code(@user.mobile, @user.sms_verification_codes.last.token)
    expect(user).to be_an_instance_of User
    expect(user.mobile_verified).to be true
  end

end

require 'v1/handshake_logic'

RSpec.describe V1::ConnectLogic do
  let(:user) { create(:user) }

  describe '.incoming' do
    it 'Access token is invalid' do
      faye_message = {"ext"=>{"access_token"=>'invalid access_token'}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/connect"}
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'AuthenticateError: Access token is invalid.'
    end

    it 'Access token is valid' do
      faye_message = {"ext"=>{"access_token"=>user.access_tokens.first.token}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/connect"}
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq nil
    end
  end
end

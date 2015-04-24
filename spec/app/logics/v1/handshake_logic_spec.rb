require 'v1/handshake_logic'

RSpec.describe V1::HandshakeLogic do
  describe '#incoming' do
    it 'Access token is invalid' do
      faye_message = {"ext"=>{"access_token"=>'invalid access_token'}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/users/xxxx/messages"}
      subject.incoming(faye_message)
      expect(faye_message['error']).to eq 'AuthenticateError: Access token is invalid.'
    end
  end
end

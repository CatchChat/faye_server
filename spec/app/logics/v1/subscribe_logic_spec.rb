require 'v1/subscribe_logic'

RSpec.describe V1::SubscribeLogic do

  describe '.incoming' do
    it 'Access token is invalid' do
      faye_message = {"ext"=>{"access_token"=>'invalid access_token'}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/users/xxxx/messages"}
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'AuthenticateError: Access token is invalid.'
    end

    it 'User is blocked' do
      user = create(:user, state: User.states[:blocked])
      faye_message = {"ext"=>{"access_token"=>user.access_tokens.first.token}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/users/#{user.encrypted_id}/messages"}
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'AuthenticateError: User is blocked.'
    end

    it 'Channel is invalid' do
      user = create(:user)
      faye_message = {"ext"=>{"access_token"=>user.access_tokens.first.token}, "clientId"=>"2np9pkowjpe3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/xxxx/#{user.encrypted_id}/messages"}
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'SubscribeError: Channel is invalid.'
    end

    it 'no permission' do
      user = create(:user)
      faye_message = {"ext"=>{"access_token"=>user.access_tokens.first.token}, "clientId"=>"2np9pkowjpe3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/users/xxxx/messages"}
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'SubscribeError: You are no permission to subscribe /users/xxxx/messages.'
    end
  end
end

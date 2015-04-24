require 'authentication'

RSpec.describe Authentication do
  class TestLogic
    include Authentication
  end

  describe '#authenticate_user' do
    let(:subject) { TestLogic.new }

    it 'success' do
      user = create(:user)
      faye_message = {"ext"=>{"access_token"=>user.access_tokens.first.token}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/users/317a0e603c9cddbdbcd626a18066ceaa/faye_messages"}
      expect(subject.authenticate_user(faye_message)).to eq user
      expect(faye_message['error']).to eq nil
    end

    it 'Access token is invalid' do
      faye_message = {"ext"=>{"access_token"=>'invalid access_token'}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/users/317a0e603c9cddbdbcd626a18066ceaa/faye_messages"}
      expect(subject.authenticate_user(faye_message)).to eq nil
      expect(faye_message['error']).to eq 'AuthenticateError: Access token is invalid.'
    end

    it 'User is blocked' do
      user = create(:user, state: User.states[:blocked])
      faye_message = {"ext"=>{"access_token"=>user.access_tokens.first.token}, "clientId"=>"2np9pkowjpt3i7m12av5hznjf622vbh", "channel"=>"/meta/subscribe", "subscription"=>"/users/317a0e603c9cddbdbcd626a18066ceaa/faye_messages"}
      expect(subject.authenticate_user(faye_message)).to eq nil
      expect(faye_message['error']).to eq 'AuthenticateError: User is blocked.'
    end
  end
end

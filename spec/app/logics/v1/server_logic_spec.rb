require 'v1/server_logic'

describe V1::ServerLogic do
  describe '.incoming' do
    describe 'publish' do
      it 'channel with version' do
        faye_message = { 'channel' => '/v1/users/xxxx/messages' }
        expect(V1::PublishLogic).to receive(:incoming).with(faye_message)
        subject.class.incoming(faye_message)
        expect(faye_message['error']).to eq nil
      end

      it 'channel without version' do
        faye_message = { 'channel' => '/users/xxxx/messages' }
        subject.class.incoming(faye_message)
        expect(faye_message['error']).to eq "405:/users/xxxx/messages:Invalid channel"
      end
    end

    it 'subscribe' do
      faye_message = { 'channel' => '/meta/subscribe' }
      expect(V1::SubscribeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq nil
    end

    it 'handshake' do
      faye_message = { 'channel' => '/meta/handshake' }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq nil
    end

    it 'unsubscribe' do
      faye_message = { 'channel' => '/meta/unsubscribe' }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq nil
    end

    it 'connect' do
      faye_message = { 'channel' => '/meta/connect' }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq nil
    end

    it 'disconnect' do
      faye_message = { 'channel' => '/meta/disconnect' }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq nil
    end

    it 'channel is invalid' do
      faye_message = { 'channel' => '/meta/invalid_channel' }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq '405:/meta/invalid_channel:Invalid channel'
    end
  end
end

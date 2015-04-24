require 'v1/server_logic'

describe V1::ServerLogic do

  describe '#incoming' do

    it 'publish' do
      faye_message = { 'channel' => '/users/xxxx/messages' }
      expect(V1::PublishLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'subscribe' do
      faye_message = { 'channel' => '/meta/subscribe' }
      expect(V1::SubscribeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'handshake' do
      faye_message = { 'channel' => '/meta/handshake' }
      expect(V1::HandshakeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end
  end

  it '#outgoing' do
    faye_message = { 'channel' => '/meta/handshake', 'ext' => { 'access_token' => 'access_token' } }
    subject.class.outgoing(faye_message)
    expect(faye_message['ext']).to eq({})
  end
end

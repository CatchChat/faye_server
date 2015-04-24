require 'v1/server_logic'

describe V1::ServerLogic do

  describe '.incoming' do

    it 'publish' do
      faye_message = { 'channel' => '/users/xxxx/messages' }
      expect(subject.class).to receive(:logic_class).with('/users/xxxx/messages').and_return(V1::PublishLogic)
      expect(V1::PublishLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'subscribe' do
      faye_message = { 'channel' => '/meta/subscribe' }
      expect(subject.class).to receive(:logic_class).with('/meta/subscribe').and_return(V1::SubscribeLogic)
      expect(V1::SubscribeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'handshake' do
      faye_message = { 'channel' => '/meta/handshake' }
      expect(subject.class).to receive(:logic_class).with('/meta/handshake').and_return(V1::HandshakeLogic)
      expect(V1::HandshakeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end
  end

  it '.outgoing' do
    faye_message = { 'channel' => '/meta/handshake', 'ext' => { 'access_token' => 'access_token' } }
    expect(subject.class).to receive(:logic_class).with('/meta/handshake').and_return(V1::HandshakeLogic)
    expect(V1::HandshakeLogic).to receive(:outgoing).with(faye_message)
    subject.class.outgoing(faye_message)
  end

  it '.logic_class' do
    expect(subject.class.send :logic_class, '/users/xxxx/messages').to eq V1::PublishLogic
    expect(subject.class.send :logic_class, '/meta/subscribe').to eq V1::SubscribeLogic
    expect(subject.class.send :logic_class, '/meta/handshake').to eq V1::HandshakeLogic
  end
end

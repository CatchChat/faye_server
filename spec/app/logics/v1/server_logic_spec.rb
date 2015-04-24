require 'v1/server_logic'

describe V1::ServerLogic do

  describe '.incoming' do

    it 'publish' do
      faye_message = { 'channel' => '/users/xxxx/messages' }
      expect(subject.class).to receive(:find_logic_class).with('/users/xxxx/messages').and_return(V1::PublishLogic)
      expect(V1::PublishLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'subscribe' do
      faye_message = { 'channel' => '/meta/subscribe' }
      expect(subject.class).to receive(:find_logic_class).with('/meta/subscribe').and_return(V1::SubscribeLogic)
      expect(V1::SubscribeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'handshake' do
      faye_message = { 'channel' => '/meta/handshake' }
      expect(subject.class).to receive(:find_logic_class).with('/meta/handshake').and_return(V1::HandshakeLogic)
      expect(V1::HandshakeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'unsubscribe' do
      faye_message = { 'channel' => '/meta/unsubscribe' }
      expect(subject.class).to receive(:find_logic_class).with('/meta/unsubscribe').and_return(V1::UnsubscribeLogic)
      expect(V1::UnsubscribeLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'connect' do
      faye_message = { 'channel' => '/meta/connect' }
      expect(subject.class).to receive(:find_logic_class).with('/meta/connect').and_return(V1::ConnectLogic)
      expect(V1::ConnectLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'disconnect' do
      faye_message = { 'channel' => '/meta/disconnect' }
      expect(subject.class).to receive(:find_logic_class).with('/meta/disconnect').and_return(V1::DisconnectLogic)
      expect(V1::DisconnectLogic).to receive(:incoming).with(faye_message)
      subject.class.incoming(faye_message)
    end

    it 'channel is invalid' do
      faye_message = { 'channel' => '/meta/invalid_channel' }
      expect(subject.class).to receive(:find_logic_class).with('/meta/invalid_channel').and_return(nil)
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'ChannelError: Channel is invalid.'
    end
  end

  it '.outgoing' do
    #faye_message = { 'channel' => '/meta/handshake', 'ext' => { 'access_token' => 'access_token' } }
    #expect(subject.class).to receive(:find_logic_class).with('/meta/handshake').and_return(V1::HandshakeLogic)
    #expect(V1::HandshakeLogic).to receive(:outgoing).with(faye_message)
    #subject.class.outgoing(faye_message)
  end

  it '.find_logic_class' do
    expect(subject.class.send :find_logic_class, '/users/xxxx/messages').to eq V1::PublishLogic
    expect(subject.class.send :find_logic_class, '/meta/handshake').to eq V1::HandshakeLogic
    expect(subject.class.send :find_logic_class, '/meta/connect').to eq V1::ConnectLogic
    expect(subject.class.send :find_logic_class, '/meta/disconnect').to eq V1::DisconnectLogic
    expect(subject.class.send :find_logic_class, '/meta/subscribe').to eq V1::SubscribeLogic
    expect(subject.class.send :find_logic_class, '/meta/unsubscribe').to eq V1::UnsubscribeLogic
    expect(subject.class.send :find_logic_class, '/meta/invalid_channel').to eq nil
  end
end

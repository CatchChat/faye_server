describe FayeServer do

  describe '#incoming' do

    it 'error' do
      count = 0
      block = -> { count + 1 }
      faye_message = { 'ext' => {} }
      expect(subject).to receive(:check_version).and_return(nil)
      expect(subject).to_not receive(:server_logic_class)
      expect(block).to receive(:call)
      subject.incoming(faye_message, block)
    end

    it 'success' do
      block = ->(_) {}
      faye_message = {}
      expect(subject).to receive(:check_version).and_return('v1')
      expect(subject).to receive(:server_logic_class).and_return(V1::ServerLogic)
      expect(V1::ServerLogic).to receive(:incoming).with(faye_message)
      expect(block).to receive(:call)
      subject.incoming(faye_message, block)
    end
  end

  it '#outgoing' do
    block = ->(_) {}
    faye_message = {}
    expect(subject).to receive(:server_logic_class).and_return(V1::ServerLogic)
    expect(V1::ServerLogic).to receive(:outgoing).with(faye_message)
    expect(block).to receive(:call)
    subject.outgoing(faye_message, block)
  end

  describe '#check_version' do

    it 'invalid version' do
      faye_message = {}
      expect(subject).to receive(:get_version).with(faye_message).and_return(nil)
      expect(subject.send :check_version, faye_message).to eq nil
      expect(faye_message['error']).to eq 'VersionError: Version is invalid.'
    end

    it 'success' do
      faye_message = {}
      expect(subject).to receive(:get_version).with(faye_message).and_return('v1')
      expect(subject.send :check_version, faye_message).to eq 'v1'
      expect(faye_message['error']).to eq nil
    end
  end

  it '#server_logic_class' do
    expect(subject.send :server_logic_class, 'v1').to eq V1::ServerLogic
    expect(subject.send :server_logic_class, 'invalid version').to eq nil
  end

  it '#not_reconnect_if_handshake_error' do
    faye_message = { 'channel' => '/meta/handshake', 'error' => 'error' }
    subject.send :not_reconnect_if_handshake_error, faye_message
    expect(faye_message).to eq({ 'channel' => '/meta/handshake', 'error' => 'error', 'advice' => { 'reconnect' => 'none' } })
  end

  it '#get_version' do
    faye_message = { 'ext' => { 'version' => 'v1' } }
    expect(subject.send :get_version, faye_message).to eq 'v1'

    faye_message = {}
    expect(subject.send :get_version, faye_message).to eq nil
  end

  it '#notice_error' do
    error = Exception.new
    faye_message = { 'ext' => { 'access_token' => 'access_token' } }
    expect(NewRelic::Agent).to receive(:notice_error).with(error, custom_params: { 'ext' => { 'access_token' => User.encrypt_id('access_token') } })
    subject.send :notice_error, error, faye_message
    expect(faye_message).to eq({ 'ext' => { 'access_token' => 'access_token' } })
  end
end

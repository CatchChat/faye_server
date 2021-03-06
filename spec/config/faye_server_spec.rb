describe FayeServer do

  describe '#incoming' do

    it 'error' do
      block = ->(_) {}
      faye_message = { 'ext' => {} }
      expect(subject).to receive(:check_version).and_return(nil)
      expect(subject).to_not receive(:server_logic_class)
      expect(block).to receive(:call).with(faye_message)
      subject.incoming(faye_message, block)
      expect(faye_message['ext']).to eq({})
    end

    it 'success' do
      block = ->(_) {}
      faye_message = {}
      custom_data = { 'version' => 'v1' }
      expect(subject).to receive(:check_version).and_return('v1')
      expect(subject).to receive(:server_logic_class).and_return(V1::ServerLogic)
      expect(V1::ServerLogic).to receive(:incoming).with({ 'custom_data' => custom_data })
      expect(block).to receive(:call).with({ 'ext' => custom_data })
      subject.incoming(faye_message, block)
      expect(faye_message['ext']).to eq(custom_data)
    end
  end

  it '#outgoing' do
    response = { 'xxxx' => 'xxxx' }
    block = ->(_) {}
    faye_message = { 'ext' => { 'response' => response } }
    #expect(subject).to receive(:server_logic_class).and_return(V1::ServerLogic)
    #expect(V1::ServerLogic).to receive(:outgoing).with(faye_message)
    expect(block).to receive(:call).with({ 'ext' => response })
    subject.outgoing(faye_message, block)
    expect(faye_message).to eq({ 'ext' => response })
  end

  describe '#check_version' do

    it 'invalid version' do
      faye_message = {}
      expect(subject).to receive(:get_version).with(faye_message).and_return(nil)
      expect(subject.send :check_version, faye_message).to eq FayeServer::VERSIONS.last
      expect(faye_message['error']).to eq nil
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
    expect(NewRelic::Agent).to receive(:notice_error).with(error, custom_params: { faye_message: { 'ext' => { 'access_token' => User.encrypt_id('access_token') } }.to_json })
    subject.send :notice_error, error, faye_message
    expect(faye_message).to eq({ 'ext' => { 'access_token' => 'access_token' } })
  end
end

RSpec.describe Faye::Server do

  describe '#make_response' do
    it do
      message = { 'ext' => 'ext' }
      expect(subject).to receive(:make_response_without_ext).with(message).and_return({ 'successful' => true })
      expect(subject.make_response(message)).to eq({ 'successful' => true, 'ext' => 'ext' })
    end
  end

  describe '#process' do
    it do
      stub_const('FayeServer::VERSIONS', %w(v1 v2 v3))
      original_messages = [
        { 'channel' => ['/users/abc123/messages', '/users/abc456/messages'] },
        { 'channel' => ['/circles/abc123/messages', '/circles/abc456/messages'] },
        { 'channel' => ['/v1/users/abc123/messages', '/v1/circles/abc123/messages'] }
      ]

      processed_messages = [
        { 'channel' => '/v1/users/abc123/messages' },
        { 'channel' => '/v2/users/abc123/messages' },
        { 'channel' => '/v3/users/abc123/messages' },
        { 'channel' => '/v1/users/abc456/messages' },
        { 'channel' => '/v2/users/abc456/messages' },
        { 'channel' => '/v3/users/abc456/messages' },
        { 'channel' => '/v1/circles/abc123/messages' },
        { 'channel' => '/v2/circles/abc123/messages' },
        { 'channel' => '/v3/circles/abc123/messages' },
        { 'channel' => '/v1/circles/abc456/messages' },
        { 'channel' => '/v2/circles/abc456/messages' },
        { 'channel' => '/v3/circles/abc456/messages' },
        { 'channel' => '/v1/users/abc123/messages' },
        { 'channel' => '/v1/circles/abc123/messages' },
      ]

      expect(subject).to receive(:process_without_dispatch).with(processed_messages, nil)
      subject.process(original_messages, nil)
    end
  end
end

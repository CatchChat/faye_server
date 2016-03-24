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
      original_messages = [
        { 'channel' => ['/users/abc123/messages', '/users/abc456/messages'] },
        { 'channel' => ['/circles/abc123/messages', '/circles/abc456/messages'] }
      ]

      processed_messages = [
        { 'channel' => '/users/abc123/messages' },
        { 'channel' => '/users/abc456/messages' },
        { 'channel' => '/circles/abc123/messages' },
        { 'channel' => '/circles/abc456/messages' }
      ]

      expect(subject).to receive(:process_without_dispatch).with(processed_messages, nil)
      subject.process(original_messages, nil)
    end
  end
end

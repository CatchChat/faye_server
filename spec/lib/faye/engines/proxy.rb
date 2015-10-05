RSpec.describe Faye::Engine::Proxy do

  describe '#publish' do
    it 'publish is no value' do
      message = { 'a' => 'b', 'ext' => {} }
      expect(subject).to receive(:publish_without_faye_server_logic).with({ 'a' => 'b' })
      subject.publish(message)
    end

    it 'publish is true' do
      message = { 'a' => 'b', 'ext' => { 'publish' => true } }
      expect(subject).to receive(:publish_without_faye_server_logic).with({ 'a' => 'b' })
      subject.publish(message)
    end

    it 'publish is false' do
      message = { 'a' => 'b', 'ext' => { 'publish' => false } }
      expect(subject).to_not receive(:publish_without_faye_server_logic)
      subject.publish(message)
    end
  end
end

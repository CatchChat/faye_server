RSpec.describe Faye::Server do
  let(:user) { create(:user) }
  let(:circle) { create(:circle) }

  describe '#make_response' do
    it do
      message = { 'ext' => 'ext' }
      expect(subject).to receive(:make_response_without_ext).with(message).and_return({ 'successful' => true })
      expect(subject.make_response(message)).to eq({ 'successful' => true, 'ext' => 'ext' })
    end
  end

  describe '#process' do
    it do
      user1 = create(:user)
      circle.users << user << user1
      stub_const('FayeServer::VERSIONS', %w(v1 v2))
      original_messages = [
        { 'channel' => '/messages', 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'User', 'recipient_id' => user.encrypted_id  } } },
        { 'channel' => '/messages', 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'User', 'recipient_id' => user.encrypted_id  } } },
        { 'channel' => '/messages', 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => '/messages', 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => '/subscribe', 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } }
      ]

      processed_messages = [
        { 'channel' => "/v1/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'User', 'recipient_id' => user.encrypted_id  } } },
        { 'channel' => "/v2/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'User', 'recipient_id' => user.encrypted_id  } } },
        { 'channel' => "/v1/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'User', 'recipient_id' => user.encrypted_id  } } },
        { 'channel' => "/v2/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'User', 'recipient_id' => user.encrypted_id  } } },
        { 'channel' => "/v1/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => "/v2/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => "/v1/users/#{user1.encrypted_id}/messages", 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => "/v2/users/#{user1.encrypted_id}/messages", 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => "/v1/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => "/v2/users/#{user.encrypted_id}/messages", 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => "/v1/users/#{user1.encrypted_id}/messages", 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => "/v2/users/#{user1.encrypted_id}/messages", 'data' => { 'message_type' => 'instant_state', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } },
        { 'channel' => '/subscribe', 'data' => { 'message_type' => 'message', 'message' => { 'recipient_type' => 'Circle', 'recipient_id' => circle.encrypted_id  } } }
      ]

      expect(subject).to receive(:process_without_dispatch).with(processed_messages, nil)
      subject.process(original_messages, nil)
    end
  end
end

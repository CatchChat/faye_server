require 'v1/publish_logic'

RSpec.describe V1::PublishLogic do
  let(:user) { create(:user) }

  describe '.incoming' do
    it 'Message type is invalid' do
      faye_message = {
        "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "invalid message_type",
          "message"      => {}
        }
      }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq "407:invalid message_type:Message type is invalid"
    end

    describe 'instant_state message' do
      it 'Access token is invalid' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>"invalid access_token"},
          "data"    => {
            "message_type" => "instant_state",
            "message"      => {},
          }
        }
        subject.class.incoming(faye_message)
        expect(faye_message['error']).to eq '401:invalid access_token:Access token is invalid'
      end

      it 'User is blocked' do
        user.update_column(:state, User.states[:blocked])
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "instant_state",
            "message"      => {},
          }
        }
        subject.class.incoming(faye_message)
        expect(faye_message['error']).to eq '401:test-token:User is blocked'
      end

      it 'PublishError: Message is invalid.' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "instant_state",
            "message"      => ""
          }
        }
        subject.class.incoming(faye_message)
        expect(faye_message['error']).to eq "407::Message is invalid"
      end

      it 'should send process method when no error' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "instant_state",
            "message"      => {}
          }
        }

        faye_message['data']['message_type'] = 'instant_state'
        expect(subject.class).to receive(:process_instant_state).with(user, faye_message)
        subject.class.incoming(faye_message)
      end
    end

    describe 'other message' do
      it 'Publish token is invalid' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"publish_token"=>"invalid publish_token"},
          "data"    => {
            "message_type" => "message",
            "message"      => {},
          }
        }
        subject.class.incoming(faye_message)
        expect(faye_message['error']).to eq "407:invalid publish_token:Publish token is invalid"
      end

      context 'message_type is mark_as_read' do
        it 'success' do
          faye_message = {
            "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
            "ext"     => {"publish_token"=>ENV['PUBLISH_TOKEN']},
            "data"    => {
              "message_type" => "mark_as_read",
              "message" => {
                "last_read_at" => 11111.111,
                "last_read_id" => 11111,
                "recipient_type" => "User",
                "recipient_id" => "ea8fb465c9fe1f7cab2b53fcf12b9b53",
                "conversation" => {
                  "type" => "User",
                  "id" => "ea8fb465c9fe1f7cab2b53fcf12b9b00"
                }
              },
            }
          }
          subject.class.incoming(faye_message)
          expect(faye_message).to eq({
            "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
            "ext"     => {"publish_token"=>ENV['PUBLISH_TOKEN']},
            "data"    => {
              "message_type" => "mark_as_read",
              "message" => {
                "last_read_at" => 11111.111,
                "last_read_id" => 11111,
                "recipient_type" => "User",
                "recipient_id" => "ea8fb465c9fe1f7cab2b53fcf12b9b00"
              },
            }
          })
        end
      end

      context 'message_type is other' do
        it 'success' do
          faye_message = {
            "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
            "ext"     => {"publish_token"=>ENV['PUBLISH_TOKEN']},
            "data"    => {
              "message_type" => "message",
              "message"      => {},
            }
          }
          subject.class.incoming(faye_message)
          expect(faye_message).to eq faye_message
        end
      end
    end
  end

  describe '.process_instant_state' do
    it 'Channel is invalid' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "instant_state",
          "message"      => { "state" => "typing" }
        }
      }
      subject.class.send :process_instant_state, user, faye_message
      expect(faye_message['error']).to eq '405:/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages:Invalid channel'
    end

    describe 'success' do
      it 'channel with version' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "instant_state",
            "message"      => { "state" => "typing", "recipient_type" => "users", "recipient_id" => "123" }
          }
        }

        subject.class.send :process_instant_state, user, faye_message
        expect(faye_message['channel']).to eq "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages"
        expect(faye_message['data']).to eq({
          'message_type' => 'instant_state',
          'message' => {
            'state' => 'typing',
            "recipient_type" => "users",
            "recipient_id" => "123",
            'user' => {
              'id' => user.encrypted_id,
              'username' => user.username,
              'nickname' => user.nickname
            }
          }
        })
      end
    end
  end
end

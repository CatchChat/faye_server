require 'v1/publish_logic'

RSpec.describe V1::PublishLogic do
  let(:user) { create(:user) }

  describe '.incoming' do
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

    it 'From api server' do
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

    it 'Access token is invalid' do
      faye_message = {
        "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>"invalid access_token"},
        "data"    => {
          "message_type" => "message",
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
          "message_type" => "message",
          "message"      => {},
        }
      }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq '401:test-token:User is blocked'
    end

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

    it 'PublishError: Message is invalid.' do
      faye_message = {
        "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "message",
          "message"      => ""
        }
      }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq "407::Message is invalid"
    end

    it 'should send process method' do
      faye_message = {
        "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "message",
          "message"      => {}
        }
      }
      subject.class::MESSAGE_TYPES.each do |message_type|
        faye_message['data']['message_type'] = message_type
        expect(subject.class).to receive("process_#{message_type}").with(user, faye_message)
        subject.class.incoming(faye_message)
      end
    end
  end

  describe '.process_message' do

    it 'Channel is invalid' do
      faye_message = {
        "channel" => "/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "message",
          "message"      => {}
        }
      }
      subject.class.send :process_message, user, faye_message
      expect(faye_message['error']).to eq '405:/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages:Invalid channel'
    end

    it 'Message can not be sent to this channel' do
      faye_message = {
        "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "message",
          "message"      => { "recipient_type" => "User", "recipient_id" => 'xxxx' }
        }
      }
      subject.class.send :process_message, user, faye_message
      expect(faye_message['error']).to eq '403:/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages:Forbidden channel'
    end

    describe 'Send request to api server' do
      it 'error' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "message",
            "message"      => { "recipient_type" => "User", "recipient_id" => 'ea8fb465c9fe1f7cab2b53fcf12b9b53' }
          }
        }

        stub_request(:post, "#{ENV['API_SERVER_URL']}/v1/messages").
         with(:body => "{\"recipient_type\":\"User\",\"recipient_id\":\"ea8fb465c9fe1f7cab2b53fcf12b9b53\",\"send_to_faye_server\":false}",
              :headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
         to_return(:status => 422, :body => "{\"error\":\"error\"}", :headers => {})

        subject.class.send :process_message, user, faye_message
        expect(faye_message['error']).to eq '407::error'
        expect(faye_message.has_key?('custom_data')).to eq false

        stub_request(:post, "#{ENV['API_SERVER_URL']}/v1/messages").
         with(:body => "{\"recipient_type\":\"User\",\"recipient_id\":\"ea8fb465c9fe1f7cab2b53fcf12b9b53\",\"send_to_faye_server\":false}",
              :headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
         to_return(:status => 422, :body => "", :headers => {})

        subject.class.send :process_message, user, faye_message
        expect(faye_message['error']).to eq '500::Internal server error'
        expect(faye_message.has_key?('custom_data')).to eq false
      end

      it 'success' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "message",
            "message"      => { "recipient_type" => "User", "recipient_id" => 'ea8fb465c9fe1f7cab2b53fcf12b9b53' }
          }
        }

        stub_request(:post, "#{ENV['API_SERVER_URL']}/v1/messages").
         with(:body => "{\"recipient_type\":\"User\",\"recipient_id\":\"ea8fb465c9fe1f7cab2b53fcf12b9b53\",\"send_to_faye_server\":false}",
              :headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
         to_return(:status => 200, :body => "{\"id\":\"asdasdsadasdsad\"}", :headers => {})

        subject.class.send :process_message, user, faye_message
        expect(faye_message['data']['message']).to eq({ "id" => "asdasdsadasdsad" })
        expect(faye_message['custom_data']['response']).to eq({ 'message' => { 'id' => 'asdasdsadasdsad' } })
      end
    end
  end

  describe '.process_instant_state' do

    it 'Channel is invalid' do
      faye_message = {
        "channel" => "/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "instant_state",
          "message"      => { "state" => "typing" }
        }
      }
      subject.class.send :process_instant_state, user, faye_message
      expect(faye_message['error']).to eq '405:/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages:Invalid channel'
    end

    it 'success' do
      faye_message = {
        "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "instant_state",
          "message"      => { "state" => "typing" }
        }
      }
      subject.class.send :process_instant_state, user, faye_message
      expect(faye_message['data']).to eq({
        'message_type' => 'instant_state',
        'message' => {
          'state' => 'typing',
          'user' => {
            'id' => user.encrypted_id,
            'username' => user.username,
            'nickname' => user.nickname
          }
        }
      })
    end
  end

  describe '.process_mark_as_read' do

    it 'Channel is invalid' do
      faye_message = {
        "channel" => "/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "mark_as_read",
          "message"      => { "last_read_at" => "", "recipient_type" => "User", "recipient_id" => "1" }
        }
      }
      subject.class.send :process_mark_as_read, user, faye_message
      expect(faye_message['error']).to eq '405:/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages:Invalid channel'
    end

    describe 'Send request to api server' do

      it 'error' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "mark_as_read",
            "message"      => { "max_id" => "10", "recipient_type" => "User", "recipient_id" => "1" }
          }
        }

        stub_request(:patch, "#{ENV['API_SERVER_URL']}/v1/User/1/messages/batch_mark_as_read").
         with(:body => %Q|{"max_id":"10","send_to_faye_server":false}|,
              :headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
         to_return(:status => 404, :body => "{\"error\":\"Message is not found\"}", :headers => {})

        subject.class.send :process_mark_as_read, user, faye_message
        expect(faye_message['error']).to eq '407::Message is not found'
        expect(faye_message.has_key?('custom_data')).to eq false

        stub_request(:patch, "#{ENV['API_SERVER_URL']}/v1/User/1/messages/batch_mark_as_read").
         with(:body => %Q|{"max_id":"10","send_to_faye_server":false}|,
              :headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
         to_return(:status => 404, :body => "", :headers => {})

        subject.class.send :process_mark_as_read, user, faye_message
        expect(faye_message['error']).to eq '500::Internal server error'
        expect(faye_message.has_key?('custom_data')).to eq false
      end

      it 'success' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "mark_as_read",
            "message"      => { "max_id" => "10", "recipient_type" => "User", "recipient_id" => "1" }
          }
        }

        stub_request(:patch, "#{ENV['API_SERVER_URL']}/v1/User/1/messages/batch_mark_as_read").
         with(:body => %Q|{"max_id":"10","send_to_faye_server":false}|,
              :headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
          to_return(:status => 200, :body => "{\"last_read_at\":1445594381.191}", :headers => {})

        subject.class.send :process_mark_as_read, user, faye_message
        expect(faye_message['data']).to eq({
          'message_type' => 'mark_as_read',
          'message' => { 'last_read_at' => 1445594381.191, 'recipient_type' => 'User', 'recipient_id' => user.encrypted_id }
        })
      end
    end
  end

  describe '.process_message_deleted' do

    it 'Channel is invalid' do
      faye_message = {
        "channel" => "/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "message_deleted",
          "message"      => { "id" => "xxxx" }
        }
      }
      subject.class.send :process_message_deleted, user, faye_message
      expect(faye_message['error']).to eq '405:/v1/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages:Invalid channel'
    end

    it 'Message id is invalid' do
      faye_message = {
        "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "message_type" => "message_deleted",
          "message"      => { "id" => "" }
        }
      }
      subject.class.send :process_message_deleted, user, faye_message
      expect(faye_message['error']).to eq '407::Message id is invalid'
    end

    describe 'Send request to api server' do

      it 'error' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "message_deleted",
            "message"      => { "id" => "xxxx" }
          }
        }

        stub_request(:delete, "#{ENV['API_SERVER_URL']}/v1/messages/xxxx?send_to_faye_server=false").
         with(:headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
         to_return(:status => 404, :body => "{\"error\":\"Message is not found\"}", :headers => {})

        subject.class.send :process_message_deleted, user, faye_message
        expect(faye_message['error']).to eq '407::Message is not found'
        expect(faye_message.has_key?('custom_data')).to eq false

        stub_request(:delete, "#{ENV['API_SERVER_URL']}/v1/messages/xxxx?send_to_faye_server=false").
         with(:headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
         to_return(:status => 404, :body => "", :headers => {})

        subject.class.send :process_message_deleted, user, faye_message
        expect(faye_message['error']).to eq '500::Internal server error'
        expect(faye_message.has_key?('custom_data')).to eq false
      end

      it 'success' do
        faye_message = {
          "channel" => "/v1/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "message_type" => "message_deleted",
            "message"      => { "id" => "xxxx" }
          }
        }

        stub_request(:delete, "#{ENV['API_SERVER_URL']}/v1/messages/xxxx?send_to_faye_server=false").
          with(:headers => {'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\""}).
          to_return(:status => 200, :body => "{\"id\":\"xxxx\",\"recipient_id\":\"ea8fb465c9fe1f7cab2b53fcf12b9b53\",\"recipient_type\":\"User\",\"sender\":{\"id\":\"ea8fb465c9fe1f7cab2b53fcf12b9b53\",\"username\":\"username\",\"nickname\":\"nickname\"}}", :headers => {})

        subject.class.send :process_message_deleted, user, faye_message
        expect(faye_message.has_key?('custom_data')).to eq false
        expect(faye_message['data']).to eq({
          'message_type' => 'message_deleted',
          'message' => {"id"=>"xxxx", "recipient_id" => "ea8fb465c9fe1f7cab2b53fcf12b9b53", "recipient_type" => "User", "sender"=>{"id"=>"ea8fb465c9fe1f7cab2b53fcf12b9b53", "username"=>"username", "nickname"=>"nickname"}}
        })
      end
    end
  end
end

require 'v1/publish_logic'

RSpec.describe V1::PublishLogic do
  let(:user) { create(:user) }

  describe '.incoming' do
    it 'Access token is invalid' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>"invalid access_token"},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "message",
          "message"      => {},
        }
      }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'AuthenticateError: Access token is invalid.'
    end

    it 'User is blocked' do
      user.update_column(:state, User.states[:blocked])
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "message",
          "message"      => {},
        }
      }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'AuthenticateError: User is blocked.'
    end

    it 'Message type is invalid' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "invalid message_type",
          "message"      => {}
        }
      }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'PublishError: Message type is invalid.'
    end

    it 'PublishError: Message is invalid.' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "message",
          "message"      => ""
        }
      }
      subject.class.incoming(faye_message)
      expect(faye_message['error']).to eq 'PublishError: Message is invalid.'
    end

    it 'should send process method' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
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
        "channel" => "/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "message",
          "message"      => {}
        }
      }
      subject.class.send :process_message, user, faye_message
      expect(faye_message['error']).to eq 'PublishError: Channel is invalid.'
    end

    it 'Message can not be sent to this channel' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "message",
          "message"      => { "recipient_type" => "users", "recipient_id" => 'xxxx' }
        }
      }
      subject.class.send :process_message, user, faye_message
      expect(faye_message['error']).to eq 'PublishError: Message can not be sent to this channel.'
    end

    describe 'Send request to api server' do
      it 'error' do
        faye_message = {
          "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "api_version"  => "v1",
            "message_type" => "message",
            "message"      => { "recipient_type" => "User", "recipient_id" => 'ea8fb465c9fe1f7cab2b53fcf12b9b53' }
          }
        }

        stub_request(:post, "#{ENV['API_SERVER_URL']}/v1/messages").
         with(:body => {"recipient_id"=>"ea8fb465c9fe1f7cab2b53fcf12b9b53", "recipient_type"=>"User"},
              :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\"", 'Content-Length'=>'65', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
         to_return(:status => 422, :body => "{\"error\":\"error\"}", :headers => {})

        subject.class.send :process_message, user, faye_message
        expect(faye_message['error']).to eq 'error'

        stub_request(:post, "#{ENV['API_SERVER_URL']}/v1/messages").
         with(:body => {"recipient_id"=>"ea8fb465c9fe1f7cab2b53fcf12b9b53", "recipient_type"=>"User"},
              :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\"", 'Content-Length'=>'65', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
         to_return(:status => 422, :body => "", :headers => {})

        subject.class.send :process_message, user, faye_message
        expect(faye_message['error']).to eq 'Internal error'
      end

      it 'success' do
        faye_message = {
          "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "api_version"  => "v1",
            "message_type" => "message",
            "message"      => { "recipient_type" => "User", "recipient_id" => 'ea8fb465c9fe1f7cab2b53fcf12b9b53' }
          }
        }

        stub_request(:post, "#{ENV['API_SERVER_URL']}/v1/messages").
         with(:body => {"recipient_id"=>"ea8fb465c9fe1f7cab2b53fcf12b9b53", "recipient_type"=>"User"},
              :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\"", 'Content-Length'=>'65', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "{\"id\":\"asdasdsadasdsad\"}", :headers => {})

        subject.class.send :process_message, user, faye_message
        expect(faye_message['data']['message']).to eq({ "id" => "asdasdsadasdsad" })
      end
    end
  end

  describe '.process_instant_state' do

    it 'Channel is invalid' do
      faye_message = {
        "channel" => "/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "instant_state",
          "message"      => { "state" => "typing" }
        }
      }
      subject.class.send :process_instant_state, user, faye_message
      expect(faye_message['error']).to eq 'PublishError: Channel is invalid.'
    end

    it 'success' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
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
        "channel" => "/xxxx/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "mark_as_read",
          "message"      => { "id" => "xxxx" }
        }
      }
      subject.class.send :process_mark_as_read, user, faye_message
      expect(faye_message['error']).to eq 'PublishError: Channel is invalid.'
    end

    it 'Message id is invalid' do
      faye_message = {
        "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
        "ext"     => {"access_token"=>user.access_tokens.first.token},
        "data"    => {
          "api_version"  => "v1",
          "message_type" => "mark_as_read",
          "message"      => { "id" => "" }
        }
      }
      subject.class.send :process_mark_as_read, user, faye_message
      expect(faye_message['error']).to eq 'PublishError: Message id is invalid.'
    end

    describe 'Send request to api server' do

      it 'error' do
        faye_message = {
          "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "api_version"  => "v1",
            "message_type" => "mark_as_read",
            "message"      => { "id" => "xxxx" }
          }
        }

        stub_request(:patch, "#{ENV['API_SERVER_URL']}/v1/messages/xxxx/mark_as_read").
         with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\"", 'Content-Length'=>'0', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
         to_return(:status => 404, :body => "{\"error\":\"Message is not found\"}", :headers => {})

        subject.class.send :process_mark_as_read, user, faye_message
        expect(faye_message['error']).to eq 'Message is not found'

        stub_request(:patch, "#{ENV['API_SERVER_URL']}/v1/messages/xxxx/mark_as_read").
         with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\"", 'Content-Length'=>'0', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
         to_return(:status => 404, :body => "", :headers => {})

        subject.class.send :process_mark_as_read, user, faye_message
        expect(faye_message['error']).to eq 'Internal error'
      end

      it 'success' do
        faye_message = {
          "channel" => "/users/ea8fb465c9fe1f7cab2b53fcf12b9b53/messages",
          "ext"     => {"access_token"=>user.access_tokens.first.token},
          "data"    => {
            "api_version"  => "v1",
            "message_type" => "mark_as_read",
            "message"      => { "id" => "xxxx" }
          }
        }

        stub_request(:patch, "#{ENV['API_SERVER_URL']}/v1/messages/xxxx/mark_as_read").
          with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>"Token token=\"#{user.access_tokens.first.token}\"", 'Content-Length'=>'0', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "{\"recipient_type\":\"user\",\"recipient_id\":\"aaaa\"}", :headers => {})

        subject.class.send :process_mark_as_read, user, faye_message
        expect(faye_message['data']).to eq({
          'message_type' => 'mark_as_read',
          'message' => { 'id' => 'xxxx', 'recipient_type' => 'user', 'recipient_id' => 'aaaa' }
        })
      end
    end
  end
end

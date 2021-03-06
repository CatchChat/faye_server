require 'v1/server_logic'

class FayeServer
  VERSIONS = %w(v1)

  def incoming(faye_message, callback)
    start_time = Time.now
    if version = check_version(faye_message)
      faye_message['custom_data'] = { 'version' => version }
      server_logic_class(version).incoming(faye_message)
    end
  rescue => e
    notice_error(e, faye_message)
    Faye.logger.error("Incoming: message: #{faye_message.inspect}\nerror: #{e.message}\n#{e.backtrace}")
    faye_message['error'] = "Internal error"
  ensure
    faye_message['ext'] = faye_message.delete('custom_data') || {}
    callback.call(faye_message)
    end_time = Time.now
    Faye.logger.info "******************** incoming perform time: #{end_time - start_time} ********************"
  end

  def outgoing(faye_message, callback)
    start_time = Time.now
    not_reconnect_if_handshake_error(faye_message)
    response = faye_message['ext']['response'] rescue nil
    faye_message['ext'] = response || {}
    callback.call(faye_message)
    end_time = Time.now
    Faye.logger.info "******************** outgoing perform time: #{end_time - start_time} ********************"
  end

  private

  def check_version(faye_message)
    version = get_version(faye_message)
    if VERSIONS.include?(version)
      version
    else
      VERSIONS.last
    end
  end

  def server_logic_class(version)
    if version == 'v1'
      V1::ServerLogic
    end
  end

  def get_version(faye_message)
    faye_message['ext']['version'] rescue nil
  end

  def not_reconnect_if_handshake_error(faye_message)
    if faye_message['channel'] == '/meta/handshake' && faye_message['error']
      faye_message['advice'] ||= {}
      faye_message['advice']['reconnect'] = 'none'
    end
  end

  def notice_error(error, faye_message)
    if access_token = faye_message['ext']['access_token'] rescue nil
      faye_message['ext']['access_token'] = User.encrypt_id(access_token)
      NewRelic::Agent.notice_error(error, custom_params: { faye_message: faye_message.to_json })
      faye_message['ext']['access_token'] = access_token
    else
      NewRelic::Agent.notice_error(error, custom_params: { faye_message: faye_message.to_json })
    end
  end
end

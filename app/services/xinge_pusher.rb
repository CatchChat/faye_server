require 'xinge'
class XingePusher

  ## options
  #   Example: { ios: { id: 'xxx', key: 'xxx' }, android: { id: 'xxx', key: 'xxx' } }
  def initialize(options = {})
    @options = options
  end

  def prepare(pusher)
    @options.merge!(pusher.options)
  end

  ## options
  #   title: String
  #   content: String
  #   extras: Hash
  #   badge: Integer
  #   sound: String
  #   environment: Boolean true: Production, false: Development
  #   accounts: String or Array
  #   content_available: 0 or 1
  def push_to_accounts(options)
    options = options.deep_dup
    if options[:environment].nil? || options[:environment]
      environment = Xinge::Pusher::IOS_ENV_PRO
    else
      environment = Xinge::Pusher::IOS_ENV_DEV
    end

    accounts = options[:accounts]
    if accounts.is_a?(Array) && accounts.size > 1
      method = :push_to_account_list
    else
      method = :push_to_single_account
      accounts = accounts[0] if accounts.is_a?(Array)
    end

    responses = []
    pusher = Xinge::Pusher.new(@options[:android][:id], @options[:android][:key])
    responses << pusher.send(method, accounts, generate_android_notification(options), device_type: Xinge::Pusher::DEVICE_TYPE_ANDROID)
    pusher = Xinge::Pusher.new(@options[:ios][:id], @options[:ios][:key])
    responses << pusher.send(method, accounts, generate_ios_notification(options), device_type: Xinge::Pusher::DEVICE_TYPE_IOS)

    responses.all?(&:success?)
  end

  private

  ## options
  #   title: String
  #   content: String
  #   extras: Hash
  def generate_android_notification(options)
    message_params = {
      title: options[:title],
      content: options[:content],
      custom_content: options[:extras],
      type: Xinge::AndroidMessage::MESSAGE_TYPE_NOTIFICATION
    }
    message_params[:style] = Xinge::Style.new(Settings.android_style.to_h.symbolize_keys)

    Xinge::AndroidMessage.new(message_params)
  end

  ## options
  #   content: String
  #   extras: Hash
  #   badge: Integer
  #   sound: String
  #   content_available: 0 or 1
  def generate_ios_notification(options)
    message_params = {
      alert: options[:content],
      custom_content: options[:extras],
      badge: options[:badge],
      content_available: options[:content_available] || 0
    }
    message_params[:sound] = 'bub3.caf' if options[:sound].blank?

    Xinge::IOSMessage.new(message_params)
  end
end

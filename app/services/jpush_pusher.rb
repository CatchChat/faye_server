require 'jpush'
class JpushPusher
  PLATFORMS = %w(ios android)

  ## options
  # - id
  # - key
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
  #   account: String
  def push_to_single_account(options)
    if options[:environment].nil? || options[:environment]
      environment = true
    else
      environment = false
    end

    payload = JPush::PushPayload.build(
      platform: JPush::Platform.new(ios: true, android: true),
      audience: JPush::Audience.build(_alias: [options[:account]]),
      notification: generate_notification(options),
      message: generate_message(options),
      options: JPush::Options.new(apns_production: environment)
    )

    result = JPush::JPushClient.new(@options[:id], @options[:key]).sendPush(payload)
    result.isok
  end

  private

  def generate_message(options)
    JPush::Message.build(
      msg_content: options[:content],
      title: options[:title],
      extras: options[:extras]
    )
  end

  def generate_ios_notification(options)
    params = {
      alert: options[:content],
      badge: options[:badge],
      extras: options[:extras],
      'content-available' => 1
    }
    params[:sound] = 'bub3.caf' if options[:sound].blank?

    JPush::IOSNotification.build(params)
  end

  def generate_android_notification(options)
    params = {
      alert: options[:content],
      title: options[:title],
      builder_id: 1,
      extras: options[:extras]
    }

    JPush::AndroidNotification.build(params)
  end

  def generate_notification(options)
    JPush::Notification.build(
      alert: options[:content],
      android: generate_android_notification(options),
      ios: generate_ios_notification(options)
    )
  end
end

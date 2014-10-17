module Xinge
  class AndroidMessage
    include Xinge::Utils::AttrsMethodsGenerator

    # 消息类型：通知
    MESSAGE_TYPE_NOTIFICATION = 1
    # 消息类型：透传消息
    MESSAGE_TYPE_MESSAGE      = 2

    VALID_KEYS = [
      # 标题，必须为字符串
      :title,
      # 内容，必须为字符串
      :content,
      # 类型，通知或消息，必须为Message.MESSAGE_TYPE_NOTIFICATION或Message.MESSAGE_TYPE_MESSAGE
      :type,
      # 消息离线存储时间，单位为秒，必须为整形，默认不存储, 最长为3天
      :expire_time,
      # 推送时间的时间戳，单位为秒，必须为整形，如果小于当前时间戳则立即发送；如果是重复推送，则代表重复推送起始时间
      :send_time,
      # 自定义的key:value参数，
      :custom_content,
      # 允许推送给用户的时段，每个元素必须是TimeInterval的实例
      :accept_time,
      # 消息风格，必须为Style的实例，仅对通知有效
      :style,
      # 点击动作，必须为ClickAction的实例，仅对通知有效
      :action,
      # 0表示按注册时提供的包名分发消息；1表示按access id分发消息，所有以该access id成功注册推送的app均可收到消息。本字段对iOS平台无效
      :multi_pkg,
      # 重复推送的次数
      :loop_times,
      # 重复推送的时间间隔，单位为天
      :loop_interval,
    ]
    DEFAULT_OPTIONS = { expire_time: 0, send_time: 0, custom_content: {}, accept_time: [], multi_pkg: 0 }
    attr_accessor :options

    def initialize(options = {})
      options.assert_valid_keys(*VALID_KEYS)
      @options = options.reverse_merge(DEFAULT_OPTIONS)
      generate_attrs_methods(VALID_KEYS, @options)
    end

    def format_send_time
      Time.at(send_time.to_i).strftime('%Y-%m-%d %H:%M:%S')
    end

    def format
      mess = { content: options[:content] }
      mess[:title]          = options[:title]          if options[:title].present?
      mess[:accept_time]    = options[:accept_time]    if options[:accept_time].present?
      mess[:custom_content] = options[:custom_content] if options[:custom_content].present?

      if type == MESSAGE_TYPE_NOTIFICATION
        mess[:action] = options[:action].format if options[:action].present?
        mess.merge(options[:style].options)     if options[:style].present?
      end

      mess.to_json
    end
  end
end

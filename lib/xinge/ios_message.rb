module Xinge
  class IOSMessage
    include Xinge::Utils::AttrsMethodsGenerator

    VALID_KEYS = [
      # 消息离线存储时间，单位为秒，必须为整形，默认不存储, 最长为3天
      :expire_time,
      # 推送时间的时间戳，单位为秒，必须为整形，如果小于当前时间戳则立即发送；如果是重复推送，则代表重复推送起始时间
      :send_time,
      # 自定义的key:value参数，
      :custom_content,
      # 允许推送给用户的时段，每个元素必须是TimeInterval的实例
      :accept_time,
      # 定义详见APNS payload中的alert字段
      :alert,
      # 整形或null，设置角标数值。定义详见APNS payload中的badge字段
      :badge,
      # 设置通知声音。定义详见APNS payload中的sound字段
      :sound,
      # 重复推送的次数
      :loop_times,
      # 重复推送的时间间隔，单位为天
      :loop_interval
    ]
    DEFAULT_OPTIONS = { expire_time: 0, send_time: 0, custom_content: {}, accept_time: [] }
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
      aps = { alert: alert }
      aps[:badge] = badge if badge.present?
      aps[:sound] = sound if sound.present?

      mess = custom_content || {}
      mess[:accept_time] = Array(accept_time).map(&:format) if accept_time.present?
      mess[:aps] = aps

      mess.to_json
    end
  end
end

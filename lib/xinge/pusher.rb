module Xinge
  class Pusher
    include Xinge::Utils::ApiSender

    # 定义api地址
    API_PUSH_TO_SINGLE_DEVICE      = 'http://openapi.xg.qq.com/v2/push/single_device'
    API_PUSH_TO_SINGLE_ACCOUNT     = 'http://openapi.xg.qq.com/v2/push/single_account'
    API_PUSH_TO_ALL_DEVICES        = 'http://openapi.xg.qq.com/v2/push/all_device'
    API_PUSH_BY_TAGS               = 'http://openapi.xg.qq.com/v2/push/tags_device'
    API_QUERY_PUSH_STATUS          = 'http://openapi.xg.qq.com/v2/push/get_msg_status'
    API_QUERY_DEVICE_NUM           = 'http://openapi.xg.qq.com/v2/application/get_app_device_num'
    API_QUERY_TAGS                 = 'http://openapi.xg.qq.com/v2/tags/query_app_tags'
    API_CANCEL_TIMING_TASK         = 'http://openapi.xg.qq.com/v2/push/cancel_timing_task'
    API_SET_TAGS                   = 'http://openapi.xg.qq.com/v2/tags/batch_set'
    API_DELETE_TAGS                = 'http://openapi.xg.qq.com/v2/tags/batch_del'
    API_QUERY_TAGS_BY_DEVICE_TOKEN = 'http://openapi.xg.qq.com/v2/tags/query_token_tags'
    API_QUERY_DEVICE_NUM_BY_TAG    = 'http://openapi.xg.qq.com/v2/tags/query_tag_token_num'

    # iOS环境：生产环境
    IOS_ENV_PRO = 1;
    # iOS环境：开发环境
    IOS_ENV_DEV = 2;

    # 消息推送适配平台：不限
    DEVICE_TYPE_ALL      = 0;
    # 消息推送适配平台：浏览器
    DEVICE_TYPE_BROWSER  = 1;
    # 消息推送适配平台：PC
    DEVICE_TYPE_PC       = 2;
    # 消息推送适配平台：Android
    DEVICE_TYPE_ANDROID  = 3;
    # 消息推送适配平台：iOS
    DEVICE_TYPE_IOS      = 4;
    # 消息推送适配平台：winPhone
    DEVICE_TYPE_WINPHONE = 5;

    # tag运算关系：AND
    TAG_OPERATION_AND = 'AND';
    # tag运算关系：OR
    TAG_OPERATION_OR  = 'OR';

    attr_accessor :access_id, :secret_key

    def initialize(access_id, secret_key, timeout = 3)
      @access_id  = access_id
      @secret_key = secret_key
      @timeout    = timeout
    end

    def common_params
      {
        access_id: @access_id,
        timestamp: Time.now.to_i,
        valid_time: 600
      }
    end

    ##
    # 推送消息给单个设备 environment
    # @param {string}   device_token          针对某一设备推送
    # @param {Message}  message               推送的消息
    # @param {int}      environment           向iOS设备推送时必填，1表示推送生产环境；2表示推送开发环境。Android可不填。
    def push_to_single_device(device_token, message, environment = nil, &block)
      fail 'device_token is invalid' if device_token.blank?
      verify_message_and_environment(message, environment)

      params = {
        expire_time: message.expire_time,
        send_time: message.format_send_time,
        device_token: device_token,
        message: message.format
      }.merge(common_params)

      if message.is_a?(Xinge::AndroidMessage)
        params[:message_type] = message.type
        params[:multi_pkg]    = message.multi_pkg
      else
        params[:message_type] = 0
        params[:environment]  = environment
      end

      send_api_request(API_PUSH_TO_SINGLE_DEVICE, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 推送消息给单个账户或别名
    # @param {int}      device_type           消息推送的适配平台
    # @param {string}   account               账户或别名
    # @param {Message}  message               推送的消息
    # @param {int}      environment           向iOS设备推送时必填，1表示推送生产环境；2表示推送开发环境。Android可不填。
    def push_to_single_account(device_type, account, message, environment = nil, &block)
      fail 'account is invalid' if account.blank?
      verify_device_type(device_type)
      verify_message_and_environment(message, environment)

      params = {
        expire_time: message.expire_time,
        send_time: message.format_send_time,
        device_type: device_type,
        account: account,
        message: message.format
      }.merge(common_params)

      if message.is_a?(Xinge::AndroidMessage)
        params[:message_type] = message.type
        params[:multi_pkg]    = message.multi_pkg
      else
        params[:message_type] = 0
        params[:environment]  = environment
      end

      send_api_request(API_PUSH_TO_SINGLE_ACCOUNT, params, 'POST', @secret_key, @timeout, block)
    end

    ##
    # 推送消息到所有设备
    # @param {int}      device_type           消息推送的适配平台
    # @param {Message}  message               推送的消息
    # @param {int}      environment           向iOS设备推送时必填，1表示推送生产环境；2表示推送开发环境。Android可不填。
    def push_to_all_devices(device_type, message, environment = nil, &block)
      verify_device_type(device_type)
      verify_message_and_environment(message, environment)

      params = {
        expire_time: message.expire_time,
        send_time: message.format_send_time,
        device_type: device_type,
        message: message.format
      }.merge(common_params)

      # 重复推送
      if message.loop_times.present? && message.loop_interval.present?
        params[:loop_times]    = message.loop_times.to_i
        params[:loop_interval] = message.loop_interval.to_i
      end

      if message.is_a?(Xinge::AndroidMessage)
        params[:message_type] = message.type
        params[:multi_pkg]    = message.multi_pkg
      else
        params[:message_type] = 0
        params[:environment]  = environment
      end

      send_api_request(API_PUSH_TO_ALL_DEVICES, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 根据指定的tag推送消息
    # @param {int}      device_type           消息推送的适配平台
    # @param {array}    tags                  指定推送目标的tag列表，每个tag是一个string
    # @param {string}   tag_operation         多个tag的运算关系，取值为AND或OR
    # @param {Message}  message               推送的消息
    # @param {int}      environment           向iOS设备推送时必填，1表示推送生产环境；2表示推送开发环境。Android可不填。
    def push_by_tags(device_type, tags, tag_operation, message, environment = nil, &block)
      tags = Array(tags).select(&:present?)

      verify_device_type(device_type)
      verify_tags_and_tag_operation(tags, tag_operation)
      verify_message_and_environment(message, environment)

      params = {
        expire_time: message.expire_time,
        send_time: message.format_send_time,
        device_type: device_type,
        tags_list: tags.to_json,
        tags_op: tag_operation,
        message: message.format
      }.merge(common_params)

      # 重复推送
      if message.loop_times.present? && message.loop_interval.present?
        params[:loop_times]    = message.loop_times.to_i
        params[:loop_interval] = message.loop_interval.to_i
      end

      if message.is_a?(Xinge::AndroidMessage)
        params[:message_type] = message.type
        params[:multi_pkg]    = message.multi_pkg
      else
        params[:message_type] = 0
        params[:environment]  = environment
      end

      send_api_request(API_PUSH_BY_TAGS, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 批量查询推送状态
    # @param {array}    push_ids               推送id数组
    def query_push_status(push_ids, &block)
      push_ids = Array(push_ids).select(&:present?)
      fail 'push_ids is invalid' if push_ids.blank?

      params = { push_ids: push_ids.map { |id| { push_id: id } } }.merge(common_params)
      send_api_request(API_QUERY_PUSH_STATUS, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 查询设备数
    def query_device_num(&block)
      send_api_request(API_QUERY_DEVICE_NUM, common_params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 查询应用标签
    # @param {int}      start                 开始位置
    # @param {int}      limit                 查询数量
    def query_tags(start: 0, limit: 100, &block)
      start = start.to_i
      limit = limit.to_i
      start = 0   if start < 0
      limit = 100 if limit < 1

      params = { start: start, limit: limit }.merge(common_params)
      send_api_request(API_QUERY_TAGS, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 取消尚未触发的定时推送任务
    # @param {int}      push_id                消息推送id
    def cancel_timing_task(push_id, &block)
      fail 'push_id is invalid' if push_id.blank?

      params = { push_id: push_id }.merge(common_params)
      send_api_request(API_CANCEL_TIMING_TASK, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 批量为token设置标签
    # @param {array}    tags_tokens_hash         tag和token的hash，每次最多设置20个token。如：{ 'tag1' => ['token1', 'token11'], 'tag2' => ['token2', 'token22'] }。
    def set_tags(tags_tokens_hash, &block)
      verify_tags_tokens_hash(tags_tokens_hash)

      tag_token_list = tags_tokens_hash.map do |tag, tokens|
        tokens.map do |token|
          [tag, token]
        end
      end

      params = { tag_token_list: tag_token_list.to_json }.merge(common_params)
      send_api_request(API_SET_TAGS, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 批量为token删除标签
    # @param {array}    tags_tokens_hash         tag和token的hash，每次最多设置20个token。如：{ 'tag1' => ['token1', 'token11'], 'tag2' => ['token2', 'token22'] }。
    def delete_tags(tags_tokens_hash, &block)
      verify_tags_tokens_hash(tags_tokens_hash)


      tag_token_list = tags_tokens_hash.map do |tag, tokens|
        tokens.map do |token|
          [tag, token]
        end
      end

      params = { tag_token_list: tag_token_list.to_json }.merge(common_params)
      send_api_request(API_DELETE_TAGS, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 根据设备token查询标签
    # @param {string}   device_token 设备token
    def query_tags_by_device_token(device_token, &block)
      fail 'device_token is invalid' if device_token.blank?

      params = { device_token: device_token }.merge(common_params)
      send_api_request(API_QUERY_TAGS_BY_DEVICE_TOKEN, params, 'POST', @secret_key, @timeout, &block)
    end

    ##
    # 根据标签查询设备数
    # @param {string}   tag      标签
    def query_device_num_by_tag(tag, &block)
      fail 'tag is invalid' if tag.blank?

      params = { tag: tag }.merge(common_params)
      send_api_request(API_QUERY_DEVICE_NUM_BY_TAG, params, 'POST', @secret_key, @timeout, &block)
    end

    private

    def verify_message_and_environment(message, environment)
      if !message.is_a?(Xinge::AndroidMessage) && !message.is_a?(Xinge::IOSMessage)
        fail 'message is invalid'
      end

      if message.is_a?(Xinge::IOSMessage) && ![IOS_ENV_PRO, IOS_ENV_DEV].include?(environment)
        fail 'environment is invalid'
      end
    end

    def verify_device_type(device_type)
      unless [DEVICE_TYPE_ALL, DEVICE_TYPE_BROWSER, DEVICE_TYPE_PC, DEVICE_TYPE_ANDROID, DEVICE_TYPE_IOS, DEVICE_TYPE_WINPHONE].include?(device_type)
        fail 'device_type is invalid'
      end
    end

    def verify_tags_and_tag_operation(tags, tag_operation)
      fail 'tags is invalid' if tags.blank?
      unless [TAG_OPERATION_AND, TAG_OPERATION_OR].include?(tag_operation)
        fail 'tag_operation is invalid'
      end
    end

    def verify_push_ids(push_ids)
      push_ids = Array(push_ids).select()
    end

    def verify_tags_tokens_hash(tags_tokens_hash)
      if tags_tokens_hash.blank? || tags_tokens_hash.values.size > 20 ||
        tags_tokens_hash.keys.select(&:blank?).present? ||
        tags_tokens_hash.values.select(&:block?).present?
        fail 'tags_tokens_hash is invalid'
      end
    end
  end
end

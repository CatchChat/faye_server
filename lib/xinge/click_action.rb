module Xinge
  class ClickAction
    include Xinge::Utils::AttrsMethodsGenerator

    # 点击动作：打开Activity或APP
    ACTION_TYPE_ACTIVITY     = 1
    # 点击动作：打开浏览器
    ACTION_TYPE_BROWSER      = 2
    # 点击动作：打开Intent
    ACTION_TYPE_INTENT       = 3
    # 点击动作：通过包名打开应用
    ACTION_TYPE_PACKAGE_NAME = 4

    VALID_KEYS = [
      # 点击后的动作
      :action_type,
      # 要打开的app或者activity,当 action_type = ACTION_TYPE_ACTIVITY 时生效
      :activity,
      # 当 action_type = ACTION_TYPE_ACTIVITY 时生效
      :aty_attr,
      # 当 action_type = ACTION_TYPE_BROWSER 时生效
      :browser,
      # 要打开的intent,当 action_type ＝ ACTION_TYPE_INTENT 时生效
      :intent,
      # 当 action_type = ACTION_TYPE_PACKAGE_NAME 时生效
      :package_name
    ]
    DEFAULT_OPTIONS = {
      action_type: ACTION_TYPE_ACTIVITY,
      activity: '',
      aty_attr: {
        # 创建通知时，intent的属性，如：intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
        if: '',
        # PendingIntent的属性，如：PendingIntent.FLAG_UPDATE_CURRENT
        pf: ''
      },
      browser: {
        # 要打开的url
        url: '',
        # 是否需要用户确认，0为否，1为是
        confirm: 0
      },
      intent: '',
      package_name: {
        # packageName：app应用拉起别的应用的包名
        packageName: '',
        # 拉起应用的下载链接，若客户端没有找到此应用会自动去下载
        packageDownloadUrl: '',
        # 是否需要用户确认，0为否，1为是
        confirm: 0
      }
    }
    attr_accessor :options

    def initialize(options = {})
      options.assert_valid_keys(*VALID_KEYS)
      @options = options.reverse_merge(DEFAULT_OPTIONS)
      generate_attrs_methods(VALID_KEYS, @options)
    end

    def format
      action = { action_type: action_type }

      case action_type
      when ACTION_TYPE_ACTIVITY
        activity_format(action)
      when ACTION_TYPE_BROWSER
        browser_format(action)
      when ACTION_TYPE_INTENT
        intent_format(action)
      when ACTION_TYPE_PACKAGE_NAME
        package_name_format(action)
      end

      action
    end

    private

    def activity_format(action)
      action[:activity] = activity if activity.present?
      if aty_attr[:if].present? || aty_attr[:pf].present?
        action[:aty_attr] = {
          if: aty_attr[:if],
          pf: aty_attr[:pf]
        }
      end
    end

    def browser_format(action)
      if browser[:url].present?
        action[:browser] = {
          url: browser[:url],
          confirm: browser[:confirm].to_i
        }
      end
    end

    def intent_format(action)
      action[:intent] = intent if intent.present?
    end

    def package_name_format(action)
      if package_name[:packageName].present?
        action[:package_name] = {
          packageName: package_name[:packageName],
          packageDownloadUrl: package_name[:packageDownloadUrl],
          confirm: package_name[:confirm].to_i
        }
      end
    end
  end
end

module Xinge
  class Style
    include Xinge::Utils::AttrsMethodsGenerator

    VALID_KEYS = [
      # 是否响铃
      :ring,
      # 铃声文件，为空则是默认铃声
      :ring_raw,
      # 是否振动
      :vibrate,
      # 是否呼吸灯
      :lights,
      # 状态栏图标文件，为空则是app icon
      :small_icon,
      # 通知栏图标文件类型，0是本地文件，1是网络图片
      :icon_yype,
      # 通知栏图片地址，可填本地文件名或图片http地址，为空则是app icon
      :icon_res,
      # 本地通知样式，含义参见终端SDK文档
      :builder_id,
      # 样式表优先级，当样式表与推送样式冲突时，0表示以新设置的推送样式为准，1表示以样式表为准
      :style_id,
      # 通知栏是否可清除，0否，1是
      :clearable,
      # 是否覆盖历史通知。大于0则会覆盖先前弹出的相同id通知，为0展示本条通知且不影响其他通知，为-1将清除先前弹出的所有通知，仅展示本条通知
      :n_id
    ]
    attr_accessor :options

    def initialize(options = {})
      options.assert_valid_keys(*VALID_KEYS)
      @options = options
      generate_attrs_methods(VALID_KEYS, @options)
    end
  end
end

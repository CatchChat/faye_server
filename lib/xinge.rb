module Xinge
  autoload :AndroidMessage, 'xinge/android_message'
  autoload :ClickAction, 'xinge/click_action'
  autoload :IOSMessage, 'xinge/ios_message'
  autoload :Pusher, 'xinge/pusher'
  autoload :Response, 'xinge/response'
  autoload :Style, 'xinge/style'
  autoload :TimeInterval, 'xinge/time_interval'

  module Utils
    autoload :ApiSender, 'xinge/utils/api_sender'
    autoload :AttrsMethodsGenerator, 'xinge/utils/attrs_methods_generator'
  end
end

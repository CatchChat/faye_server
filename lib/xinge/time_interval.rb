module Xinge
  class TimeInterval
    attr_accessor :start_hour, :start_min, :end_hour, :end_min

    ##
    # 表示一个允许推送的时间闭区间，从 start_hour:start_min 到 end_hour:end_min
    # @param {int} start_hour 开始小时
    # @param {int} start_min  开始分钟
    # @param {int} end_hour   结束小时
    # @param {int} end_min    结束分钟
    def initialize(start_hour, start_min, end_hour, end_min)
      @start_hour = start_hour.to_i
      @start_min  = start_min.to_i
      @end_hour   = end_hour.to_i
      @end_min    = end_min.to_i

      if @start_hour < 0 || @start_hour > 23 || @start_min < 0 || @start_min > 59 ||
        @end_hour < 0 || @end_hour > 23 || @end_min < 0 || @end_min > 59
        fail 'start_hour or start_min or end_hour or end_min is invalid'
      end
    end

    def format
      {
        start: { hour: @start_hour.to_s.rjust(2, '0'), min: @start_min.to_s.rjust(2, '0') },
        end: { hour: @end_hour.to_s.rjust(2, '0'), min: @end_min.to_s.rjust(2, '0') }
      }
    end
  end
end

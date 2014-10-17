require 'json'
require 'forwardable'
module Xinge
  class Response
    extend Forwardable
    def_delegators :@resp, :ret_code, :err_msg, :result

    def initialize(resp_text)
      @resp = OpenStruct.new JSON.parse(resp_text)
    end

    def success?
      ret_code.to_s == '0'
    end
  end
end

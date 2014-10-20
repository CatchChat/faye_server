require 'spec_helper'
require 'xinge'
describe Xinge::Response do
  let(:success_resp) { "{\"ret_code\":0,\"err_msg\":\"test\",\"result\":{\"status\":0}}" }
  let(:fail_resp) { "{\"ret_code\":1,\"err_msg\":\"error\",\"result\":{\"status\":1}}" }

  describe '#success?' do
    it 'return true' do
      expect(Xinge::Response.new(success_resp).success?).to eq true
    end

    it 'return false' do
      expect(Xinge::Response.new(fail_resp).success?).to eq false
    end
  end

  describe 'forward methods' do
    subject { Xinge::Response.new(success_resp) }

    it '#ret_code' do
      expect(subject.ret_code).to eq 0
    end

    it '#err_msg' do
      expect(subject.err_msg).to eq 'test'
    end

    it '#result' do
      expect(subject.result).to eq('status' => 0)
    end
  end
end

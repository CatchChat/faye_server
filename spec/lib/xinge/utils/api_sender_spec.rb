require 'spec_helper'
require 'xinge'
describe Xinge::Utils::ApiSender do

  class DummyClass
    include Xinge::Utils::ApiSender
  end

  let(:dummy_class) { DummyClass.new }

  it 'There should be a send_api_request method' do
    expect(dummy_class.respond_to?(:send_api_request)).to eq(true)
  end

  it '#verify_method!' do
    method = 'post'
    dummy_class.send :verify_method!, method
    expect(method).to eq('POST')

    method = 'get'
    dummy_class.send :verify_method!, method
    expect(method).to eq('GET')

    ['delete', 'put', 'patch'].each do |m|
      expect { dummy_class.send :verify_method!, m }.to raise_error('method is invalid')
    end
  end

  it '#generate_sign' do
    expect(
      dummy_class.generate_sign(
        'http://openapi.xg.qq.com/v2/push/single_device',
        { test: 'test' }, 'POST', 'secret_key')
    ).to eq('2683e052f71e1f3797ff2e35318ab3e5')
  end
end

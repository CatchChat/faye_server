require 'spec_helper'
require 'xinge'
describe Xinge::Utils::AttrsMethodsGenerator do

  class DummyClass
    include Xinge::Utils::AttrsMethodsGenerator
    attr_accessor :options

    def initialize(options = {})
      @options = options
    end
  end

  let(:options) { { a: 1, b: 2, c: 3 } }
  let(:dummy_class) { DummyClass.new(options) }

  describe '#generate_attrs_methods' do

    it '生成 attrs methods' do
      attrs_methods = options.keys
      expect(dummy_class.public_methods & attrs_methods).to eq []
      dummy_class.send :generate_attrs_methods, attrs_methods, dummy_class.options
      expect(dummy_class.public_methods & attrs_methods).to eq attrs_methods
    end

    it '生成的 attrs read method 正确' do
      dummy_class.send :generate_attrs_methods, options.keys, dummy_class.options
      expect(dummy_class.a).to eq 1
      expect(dummy_class.b).to eq 2
      expect(dummy_class.c).to eq 3
      expect(dummy_class.options).to eq(options)
    end

    it '生成的 attrs write method 正确' do
      dummy_class.send :generate_attrs_methods, options.keys, dummy_class.options
      dummy_class.a = 10
      dummy_class.b = 20
      dummy_class.c = 30
      expect(dummy_class.a).to eq 10
      expect(dummy_class.b).to eq 20
      expect(dummy_class.c).to eq 30
      expect(dummy_class.options).to eq(a: 10, b: 20, c: 30)
    end
  end
end

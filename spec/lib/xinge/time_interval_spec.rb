require 'spec_helper'
require 'xinge'
describe Xinge::TimeInterval do
  describe '#initialize' do
    it 'Invalid time parameter should raise an error' do
      expect { Xinge::TimeInterval.new(-1, 0, 0, 0) }.
        to raise_error('start_hour or start_min or end_hour or end_min is invalid')
    end

    it 'Right time parameters does not raise an error' do
      expect { Xinge::TimeInterval.new(0, 0, 0, 0) }.to_not raise_error
    end
  end

  it '#format' do
    expect(Xinge::TimeInterval.new(1, 1, 1, 1).format).
      to eq({ start: { hour: '01', min: '01' }, end: { hour: '01', min: '01' } })
  end
end

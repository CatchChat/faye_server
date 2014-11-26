require 'rails_helper'

RSpec.describe PhoneNumberParser, :type => :model do
  class TestPhoneNumber
    include PhoneNumberParser
  end

  describe '.parse' do

    it 'Invalid number' do
      expect(TestPhoneNumber.parse_number('1515816637d')).to eq []
    end

    it 'No country code' do
      expect(TestPhoneNumber.parse_number('18668158203')).to eq [nil, '18668158203']
    end

    it 'have country code' do
      expect(TestPhoneNumber.parse_number('+8618668158203')).to eq ['86', '18668158203']
    end
  end
end

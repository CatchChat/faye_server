require 'rails_helper'

RSpec.describe Contact, :type => :model do

  it '.encrypt_number' do
    expect(Contact.encrypt_number('18668158203')).
      to eq '29e0fdf4524f8ecca524e844f24527c9f8d1203e184734d23f3614e989ed085f'

    expect(Contact.encrypt_number('+8618668158203')).
      to eq '29e0fdf4524f8ecca524e844f24527c9f8d1203e184734d23f3614e989ed085f'
  end
end

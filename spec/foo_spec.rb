require 'rails_helper'
describe 'foo' do
  it "verify rspec works" do


    user = FactoryGirl.build :user
    expect(1).to be 1

  end

end

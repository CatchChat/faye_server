require 'rails_helper'
require 'timecop'

RSpec.describe Friendship, :type => :model do
  let(:user) { FactoryGirl.create(:user, username: 'user') }
  let(:friend) { FactoryGirl.create(:user, username: 'friend') }
end

# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :user do
    username 'ruanwztest'
    password 'ruanwztest'
    node_id '542a22ae4b44684f2ecb2398'
    node_password '62d30f88375b7f4f1461aa0e19b47e6e52c6141409a8c5e6bcb2c45e8186a4a1'
    node_token 'o1U8LNPvh1VX0R0M'
    access_token
    sms_verification_code

  end
  factory :access_token do
    token 'test-token'
  end

  factory :sms_verification_code do
    token 'test-token'
  end
end



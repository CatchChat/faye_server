# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :user, class: User do
    username 'ruanwztest'
    password 'ruanwztest'
    phone_code '86'
    node_password '62d30f88375b7f4f1461aa0e19b47e6e52c6141409a8c5e6bcb2c45e8186a4a1'
    node_token 'o1U8LNPvh1VX0R0M'

    transient do
      tokens_count 1
      sms_code_count 1
      groups_count 1
      message_count 1
    end
    after(:create) do |user, evaluator|
      create_list(:access_token, evaluator.tokens_count, user: user)
      create_list(:sms_verification_code, evaluator.sms_code_count, user: user)
      create_list(:group, evaluator.groups_count, owner: user)
      create_list(:message, evaluator.message_count, sender: user, recipient: user)
    end
  end

  factory :access_token do
    token 'test-token'
    active true
    expired_at Time.now + 1000
  end

  factory :sms_verification_code do
    mobile '1234567'
    phone_code '86'
    token 'test-token'
    active true
    expired_at Time.now + 1000
  end

  factory :group do
    sequence :name do |n|
      "group#{n}"
    end
  end
  factory :message do
    recipient_type  'User'
    media_type  Message.media_types['image']
    state Message::STATES[:draft]
  end
end



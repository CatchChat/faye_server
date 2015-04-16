# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :user, class: User do
    sequence(:username) { |n| "username#{n}" }
    sequence(:mobile) { |n| "1515816#{n.to_s.rjust(4, '0')}" }
    sequence(:nickname) { |n| "nickname#{n}" }
    latitude '12.12'
    longitude '34.34'
    phone_code '86'
    last_sign_in_at 3.days.ago

    transient do
      tokens_count 1
    end

    after(:create) do |user, evaluator|
      create_list(:access_token, evaluator.tokens_count, user: user)
    end
  end

  factory :access_token do
    token 'test-token'
    active true
    expired_at Time.now.utc + 3600*24*365
  end
end

FactoryGirl.define do
  factory :circle, class: Circle do
    sequence(:name) { |n| "name#{n}" }
    association :creator, factory: :user
  end
end

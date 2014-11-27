FactoryGirl.define do
  factory :attachment do
    storage 'qiniu'
    file    'test-key'
  end
end

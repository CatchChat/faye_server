FactoryGirl.define do
  factory :attachment do
    storage 'qiniu'
    file    'thisisuuid'
  end
end

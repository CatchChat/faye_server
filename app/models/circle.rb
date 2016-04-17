class Circle < ActiveRecord::Base
  has_many :circles_users
  has_many :users, through: :circles_users
  belongs_to :creator, class_name: 'User'
end

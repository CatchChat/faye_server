class User < ActiveRecord::Base
  has_many :access_tokens, :dependent => :delete_all

  enum state: { active: 1, blocked: 2 }
end

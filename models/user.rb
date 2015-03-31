class User < ActiveRecord::Base
  has_many :access_tokens, :dependent => :delete_all
end

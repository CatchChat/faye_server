require 'mongoid'
Mongoid.load!(Rails.root.join 'config/mongoid.yml')

module MongoModels
  class FriendList
    include Mongoid::Document
    store_in collection: "friendlists"

    field :contacts
    field :created_at
    field :owner

    belongs_to :user, :foreign_key => "owner", :class_name => "MongoModels::User", :inverse_of => 'friend_list'
  end

  class User
    include Mongoid::Document
    store_in collection: "users"
    field :avatar
    field :blocked
    field :can_security_code_login
    field :client_mode
    field :contacts
    field :created_at
    field :friend_requests
    field :groups
    field :isAdmin
    field :isSealed
    field :login_times
    field :nickname
    field :oauthes
    field :password
    field :pending
    field :phone_area_code
    field :phone_verified
    field :region
    field :token
    field :username

    def friend_list
      FriendList.find_by owner: self.id.to_s
    rescue Mongoid::Errors::DocumentNotFound => e
      #put e.message
      []
    end
  end

  class Message
    include Mongoid::Document
    store_in collection: "messages"

    field :attachment
    field :from_nickname
    field :from_avatar
    field :from_username
    field :from_id
    field :type
    field :latitude
    field :longitude
    field :message
    field :to_id
    field :battery_level
    field :created_at
    field :group
    field :read

    def to_user
      User.find_by id: to_id
    end

    def from_user
      User.find_by id: from_id
    end
  end


  class VerifyPhone
    include Mongoid::Document
    store_in collection: "vertifyphones"

    field :phone_number
    field :verify_code
    field :phone_area_code
    field :created_at
  end
end

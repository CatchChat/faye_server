require 'mongoid'
require_relative './mongo_models'
include MongoModels
desc "import data from mongodb"
task :import_mongo do
  user         = MongoModels::User.first
  message      = MongoModels::Message.first
  friend_list  = MongoModels::FriendList.first
  verify_phone = MongoModels::VerifyPhone.first
  binding.pry
  

end


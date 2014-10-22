require 'mongoid'
require_relative './mongo_models'
include MongoModels
desc "import data from mongodb"
task :import_mongo do
  p user = MongoModels::User.first
  p message = MongoModels::Message.first
  p friend_list = MongoModels::FriendList.first
  p verify_phone = MongoModels::VerifyPhone.first
  

end


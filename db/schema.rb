# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141217084549) do

  create_table "access_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "expired_at"
    t.boolean  "active"
    t.string   "creator_ip"
    t.integer  "client",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_tokens", ["user_id"], name: "index_access_tokens_on_user_id", using: :btree

  create_table "attachments", force: true do |t|
    t.string   "storage"
    t.string   "file"
    t.string   "fallback_storage"
    t.string   "fallback_file"
    t.boolean  "public",           default: false, null: false
    t.boolean  "reserved",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["fallback_file"], name: "index_attachments_on_fallback_file", length: {"fallback_file"=>191}, using: :btree
  add_index "attachments", ["file"], name: "index_attachments_on_file", length: {"file"=>191}, using: :btree

  create_table "attachments_messages", force: true do |t|
    t.integer  "attachment_id"
    t.integer  "message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments_messages", ["attachment_id"], name: "index_attachments_messages_on_attachment_id", using: :btree
  add_index "attachments_messages", ["message_id"], name: "index_attachments_messages_on_message_id", using: :btree

  create_table "attachments_official_messages", force: true do |t|
    t.integer  "attachment_id"
    t.integer  "official_message_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments_official_messages", ["attachment_id"], name: "index_attachments_official_messages_on_attachment_id", using: :btree
  add_index "attachments_official_messages", ["official_message_id"], name: "index_attachments_official_messages_on_official_message_id", using: :btree

  create_table "attachments_reports", force: true do |t|
    t.integer  "attachment_id"
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments_reports", ["attachment_id"], name: "index_attachments_reports_on_attachment_id", using: :btree
  add_index "attachments_reports", ["report_id"], name: "index_attachments_reports_on_report_id", using: :btree

  create_table "contacts", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "encrypted_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["encrypted_number"], name: "index_contacts_on_encrypted_number", length: {"encrypted_number"=>191}, using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "friend_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.integer  "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friend_requests", ["friend_id"], name: "index_friend_requests_on_friend_id", using: :btree
  add_index "friend_requests", ["user_id"], name: "index_friend_requests_on_user_id", using: :btree

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "contact_name"
    t.string   "remarked_name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["position"], name: "index_friendships_on_position", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "friendships_groups", force: true do |t|
    t.integer  "group_id"
    t.integer  "friendship_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships_groups", ["friendship_id"], name: "index_friendships_groups_on_friendship_id", using: :btree
  add_index "friendships_groups", ["group_id"], name: "index_friendships_groups_on_group_id", using: :btree

  create_table "groups", force: true do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["owner_id"], name: "index_groups_on_owner_id", using: :btree
  add_index "groups", ["position"], name: "index_groups_on_position", using: :btree

  create_table "individual_recipients", force: true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.integer  "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "individual_recipients", ["message_id"], name: "index_individual_recipients_on_message_id", using: :btree
  add_index "individual_recipients", ["user_id"], name: "index_individual_recipients_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.integer  "media_type",                default: 0,  null: false
    t.text     "text_content"
    t.integer  "parent_id",                 default: 0,  null: false
    t.integer  "state"
    t.float    "longitude",      limit: 24
    t.float    "latitude",       limit: 24
    t.integer  "battery_level",             default: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["parent_id"], name: "index_messages_on_parent_id", using: :btree
  add_index "messages", ["recipient_id", "recipient_type"], name: "index_messages_on_recipient_id_and_recipient_type", length: {"recipient_id"=>nil, "recipient_type"=>191}, using: :btree
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree

  create_table "official_messages", force: true do |t|
    t.integer  "attachment_id"
    t.integer  "media_type"
    t.string   "text_content"
    t.float    "longitude",     limit: 24
    t.float    "latitude",      limit: 24
    t.integer  "battery_level",            default: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "official_messages", ["attachment_id"], name: "index_official_messages_on_attachment_id", using: :btree

  create_table "reports", force: true do |t|
    t.integer  "whistleblower_id"
    t.integer  "message_id"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.integer  "media_type",                  default: 0,  null: false
    t.text     "text_content"
    t.integer  "parent_id",                   default: 0,  null: false
    t.integer  "state"
    t.float    "longitude",        limit: 24
    t.float    "latitude",         limit: 24
    t.integer  "battery_level",               default: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reports", ["message_id"], name: "index_reports_on_message_id", using: :btree
  add_index "reports", ["recipient_id", "recipient_type"], name: "index_reports_on_recipient_id_and_recipient_type", length: {"recipient_id"=>nil, "recipient_type"=>191}, using: :btree
  add_index "reports", ["sender_id"], name: "index_reports_on_sender_id", using: :btree
  add_index "reports", ["whistleblower_id"], name: "index_reports_on_whistleblower_id", using: :btree

  create_table "sms_verification_codes", force: true do |t|
    t.integer  "user_id"
    t.string   "mobile"
    t.string   "token"
    t.datetime "expired_at"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_code", default: "86"
  end

  add_index "sms_verification_codes", ["mobile"], name: "index_sms_verification_codes_on_mobile", length: {"mobile"=>191}, using: :btree
  add_index "sms_verification_codes", ["token"], name: "index_sms_verification_codes_on_token", length: {"token"=>191}, using: :btree
  add_index "sms_verification_codes", ["user_id"], name: "index_sms_verification_codes_on_user_id", using: :btree

  create_table "unfriend_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unfriend_requests", ["friend_id"], name: "index_unfriend_requests_on_friend_id", using: :btree
  add_index "unfriend_requests", ["user_id"], name: "index_unfriend_requests_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",               default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "password_salt"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "nickname"
    t.string   "email"
    t.string   "mobile"
    t.boolean  "mobile_verified",        default: false, null: false
    t.string   "phone_code",             default: "86",  null: false
    t.boolean  "admin",                  default: false, null: false
    t.integer  "state"
    t.string   "avatar_url"
    t.string   "pusher_id"
    t.string   "node_token"
    t.string   "node_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, length: {"email"=>191}, using: :btree
  add_index "users", ["mobile", "phone_code"], name: "index_users_on_mobile_and_phone_code", unique: true, length: {"mobile"=>191, "phone_code"=>191}, using: :btree
  add_index "users", ["node_password"], name: "index_users_on_node_password", length: {"node_password"=>191}, using: :btree
  add_index "users", ["node_token"], name: "index_users_on_node_token", length: {"node_token"=>191}, using: :btree
  add_index "users", ["pusher_id"], name: "index_users_on_pusher_id", unique: true, length: {"pusher_id"=>191}, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, length: {"reset_password_token"=>191}, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, length: {"username"=>191}, using: :btree

end

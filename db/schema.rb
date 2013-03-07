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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130306011454) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.string   "twitter"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "dms", :force => true do |t|
    t.integer  "twitter_account_id"
    t.string   "text"
    t.datetime "received"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "sender"
  end

  create_table "galleries", :force => true do |t|
    t.integer  "product_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "for_slider"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "galleries", ["product_id"], :name => "index_galleries_on_product_id"

  create_table "orders", :force => true do |t|
    t.integer  "city_id"
    t.integer  "product_id"
    t.string   "size"
    t.string   "name"
    t.boolean  "paid"
    t.integer  "payment_id"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "user_id"
    t.string   "paypal_customer_token"
    t.string   "paypal_recurring_profile_token"
    t.boolean  "charged_back"
    t.boolean  "charged_was_made"
    t.boolean  "sended",                         :default => false
    t.string   "message"
  end

  create_table "pages", :force => true do |t|
    t.text     "about_us"
    t.text     "faq"
    t.text     "contact_us"
    t.text     "conditions"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "cost"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "charged_back"
    t.datetime "release_date"
    t.string   "charge_back_comment"
  end

  create_table "twitter_accounts", :force => true do |t|
    t.text     "name"
    t.text     "comment"
    t.integer  "last_checked"
    t.text     "consumer_key"
    t.text     "consumer_secret"
    t.text     "oauth_token"
    t.text     "oauth_token_secret"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "works"
    t.string   "password"
    t.integer  "city_id"
    t.integer  "last_used"
    t.string   "following"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

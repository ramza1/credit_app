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

ActiveRecord::Schema.define(:version => 20130609113645) do

  create_table "active_users", :force => true do |t|
    t.string   "phone_number"
    t.string   "jid"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "active_users", ["jid"], :name => "index_active_users_on_jid"
  add_index "active_users", ["phone_number"], :name => "index_active_users_on_phone_number", :unique => true

  create_table "airtimes", :force => true do |t|
    t.decimal  "price",         :precision => 10, :scale => 0, :default => 0,     :null => false
    t.string   "encrypted_pin"
    t.string   "card_type"
    t.boolean  "sold",                                         :default => false
    t.string   "name"
    t.string   "state"
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  create_table "bulk_credits", :force => true do |t|
    t.decimal  "amount",     :precision => 10, :scale => 0, :default => 0, :null => false
    t.string   "name"
    t.decimal  "unit",       :precision => 10, :scale => 0, :default => 0, :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  create_table "orders", :force => true do |t|
    t.string   "name"
    t.decimal  "amount",               :precision => 10, :scale => 0, :default => 0, :null => false
    t.string   "type"
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "state"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.integer  "transaction_id"
    t.string   "payment_method"
    t.string   "response_code"
    t.string   "response_description"
  end

  add_index "orders", ["item_id"], :name => "index_orders_on_item_id"
  add_index "orders", ["item_type"], :name => "index_orders_on_item_type"
  add_index "orders", ["transaction_id"], :name => "index_orders_on_transaction_id", :unique => true
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "payments", :force => true do |t|
    t.string   "payment_reference"
    t.string   "retrieval_reference_number"
    t.integer  "order_id"
    t.string   "card_number"
    t.date     "transaction_date"
    t.decimal  "amount",                     :precision => 10, :scale => 0, :default => 0, :null => false
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
  end

  add_index "payments", ["order_id"], :name => "index_payments_on_order_id", :unique => true
  add_index "payments", ["payment_reference"], :name => "index_payments_on_payment_reference", :unique => true
  add_index "payments", ["retrieval_reference_number"], :name => "index_payments_on_retrieval_reference_number", :unique => true

  create_table "platforms", :force => true do |t|
    t.string   "os_name"
    t.integer  "download_count"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "releases", :force => true do |t|
    t.integer  "platform_id"
    t.string   "version"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "dist_file_name"
    t.string   "dist_content_type"
    t.integer  "dist_file_size"
    t.datetime "dist_updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "name"
    t.string   "subscription_duration"
    t.boolean  "sms_notification",       :default => false
    t.string   "phone_number"
    t.boolean  "admin",                  :default => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "authentication_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "wallets", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "account_balance", :precision => 10, :scale => 0, :default => 0
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
  end

end

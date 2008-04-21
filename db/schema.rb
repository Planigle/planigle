# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 8) do

  create_table "individuals", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "email",                     :limit => 100
    t.string   "first_name",                :limit => 40
    t.string   "last_name",                 :limit => 40
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.boolean  "enabled",                                  :default => true
  end

  create_table "iterations", :force => true do |t|
    t.string  "name"
    t.date    "start"
    t.integer "length", :default => 2
  end

  create_table "stories", :force => true do |t|
    t.string  "name",                :limit => 40,                                              :null => false
    t.text    "description",                                                                    :null => false
    t.text    "acceptance_criteria",                                                            :null => false
    t.decimal "effort",                            :precision => 7, :scale => 2
    t.integer "status_code",                                                     :default => 0, :null => false
    t.integer "priority"
    t.integer "iteration_id"
    t.integer "individual_id"
  end

  create_table "tasks", :force => true do |t|
    t.string  "name",          :limit => 40,                                              :null => false
    t.text    "description"
    t.decimal "effort",                      :precision => 7, :scale => 2
    t.integer "status_code",                                               :default => 0, :null => false
    t.integer "individual_id"
    t.integer "story_id"
  end

end

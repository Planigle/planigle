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

ActiveRecord::Schema.define(version: 62) do

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.string   "auditable_name",  limit: 255
    t.integer  "project_id",      limit: 4
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.text     "comment",         limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "request_uuid",    limit: 255
    t.string   "remote_address",  limit: 255
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["project_id"], name: "project_index", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name",                        limit: 40, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.date     "premium_expiry"
    t.integer  "premium_limit",               limit: 4
    t.datetime "last_notified_of_expiration"
  end

  create_table "criteria", force: :cascade do |t|
    t.text    "description", limit: 65535,                                     null: false
    t.integer "status_code", limit: 4,                             default: 0, null: false
    t.integer "story_id",    limit: 4
    t.decimal "priority",                  precision: 9, scale: 5
  end

  add_index "criteria", ["story_id"], name: "index_criteria_on_story_id", using: :btree

  create_table "errors", force: :cascade do |t|
    t.integer  "individual_id", limit: 4,    null: false
    t.datetime "time",                       null: false
    t.string   "message",       limit: 256,  null: false
    t.string   "stack_trace",   limit: 8192, null: false
  end

  create_table "individual_story_attributes", force: :cascade do |t|
    t.integer "individual_id",      limit: 4,                                         null: false
    t.integer "story_attribute_id", limit: 4,                                         null: false
    t.integer "width",              limit: 4,                                         null: false
    t.decimal "ordering",                     precision: 9, scale: 5
    t.boolean "show",               limit: 1,                         default: false, null: false
  end

  create_table "individuals", force: :cascade do |t|
    t.string   "login",                     limit: 40
    t.string   "email",                     limit: 100
    t.string   "first_name",                limit: 40
    t.string   "last_name",                 limit: 40
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.boolean  "enabled",                   limit: 1,   default: true
    t.integer  "role",                      limit: 4
    t.datetime "last_login"
    t.datetime "accepted_agreement"
    t.integer  "team_id",                   limit: 4
    t.string   "phone_number",              limit: 20
    t.integer  "notification_type",         limit: 4,   default: 0
    t.integer  "company_id",                limit: 4
    t.integer  "selected_project_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "refresh_interval",          limit: 4,   default: 300000
  end

  add_index "individuals", ["company_id"], name: "index_individuals_on_company_id", using: :btree
  add_index "individuals", ["remember_token"], name: "index_individuals_on_remember_token", using: :btree

  create_table "individuals_projects", id: false, force: :cascade do |t|
    t.integer "project_id",    limit: 4
    t.integer "individual_id", limit: 4
  end

  add_index "individuals_projects", ["individual_id"], name: "index_individuals_projects_on_individual_id", using: :btree
  add_index "individuals_projects", ["project_id"], name: "index_individuals_projects_on_project_id", using: :btree

  create_table "iteration_story_totals", force: :cascade do |t|
    t.integer "iteration_id", limit: 4
    t.date    "date"
    t.integer "team_id",      limit: 4
    t.decimal "created",                precision: 7, scale: 2
    t.decimal "in_progress",            precision: 7, scale: 2
    t.decimal "blocked",                precision: 7, scale: 2
    t.decimal "done",                   precision: 7, scale: 2
  end

  create_table "iteration_totals", force: :cascade do |t|
    t.integer "iteration_id", limit: 4
    t.date    "date"
    t.decimal "created",                precision: 7, scale: 2
    t.decimal "in_progress",            precision: 7, scale: 2
    t.decimal "done",                   precision: 7, scale: 2
    t.integer "team_id",      limit: 4
    t.decimal "blocked",                precision: 7, scale: 2
  end

  create_table "iteration_velocities", force: :cascade do |t|
    t.integer "iteration_id", limit: 4
    t.integer "team_id",      limit: 4
    t.decimal "attempted",              precision: 7, scale: 2
    t.decimal "completed",              precision: 7, scale: 2
    t.decimal "lead_time",              precision: 7, scale: 2
    t.decimal "cycle_time",             precision: 7, scale: 2
    t.integer "num_stories",  limit: 4
  end

  create_table "iterations", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.date     "start"
    t.integer  "project_id",            limit: 4
    t.text     "retrospective_results", limit: 65535
    t.date     "finish",                                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "notable",               limit: 40,    default: ""
  end

  add_index "iterations", ["project_id"], name: "index_iterations_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                        limit: 40,                    null: false
    t.text     "description",                 limit: 65535
    t.string   "survey_key",                  limit: 40,                    null: false
    t.integer  "survey_mode",                 limit: 4,                     null: false
    t.integer  "company_id",                  limit: 4
    t.boolean  "track_actuals",               limit: 1,     default: false, null: false
    t.datetime "last_notified_of_inactivity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "projects", ["company_id"], name: "index_projects_on_company_id", using: :btree
  add_index "projects", ["survey_key"], name: "index_projects_on_survey_key", unique: true, using: :btree

  create_table "release_totals", force: :cascade do |t|
    t.integer "release_id",  limit: 4
    t.integer "team_id",     limit: 4
    t.date    "date"
    t.decimal "created",               precision: 7, scale: 2
    t.decimal "in_progress",           precision: 7, scale: 2
    t.decimal "done",                  precision: 7, scale: 2
    t.decimal "blocked",               precision: 7, scale: 2
  end

  create_table "releases", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.string   "name",       limit: 255
    t.date     "start"
    t.date     "finish"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "releases", ["project_id"], name: "index_releases_on_project_id", using: :btree

  create_table "stories", force: :cascade do |t|
    t.string   "name",           limit: 250,                                            null: false
    t.text     "description",    limit: 65535
    t.decimal  "effort",                       precision: 7,  scale: 2
    t.integer  "status_code",    limit: 4,                              default: 0,     null: false
    t.decimal  "priority",                     precision: 11, scale: 5
    t.integer  "iteration_id",   limit: 4
    t.integer  "individual_id",  limit: 4
    t.integer  "project_id",     limit: 4
    t.boolean  "is_public",      limit: 1,                              default: false
    t.decimal  "user_priority",                precision: 7,  scale: 3
    t.integer  "release_id",     limit: 4
    t.integer  "team_id",        limit: 4
    t.text     "reason_blocked", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "story_id",       limit: 4
    t.datetime "in_progress_at"
    t.datetime "done_at"
  end

  add_index "stories", ["project_id", "iteration_id"], name: "index_stories_on_project_id_and_iteration_id", using: :btree
  add_index "stories", ["project_id", "status_code"], name: "index_stories_on_project_id_and_status_code", using: :btree
  add_index "stories", ["story_id"], name: "index_stories_on_story_id", using: :btree

  create_table "story_attribute_values", force: :cascade do |t|
    t.integer "story_attribute_id", limit: 4
    t.integer "release_id",         limit: 4
    t.text    "value",              limit: 255
  end

  add_index "story_attribute_values", ["story_attribute_id"], name: "index_story_attribute_values_on_story_attribute_id", using: :btree

  create_table "story_attributes", force: :cascade do |t|
    t.integer "project_id", limit: 4,                                          null: false
    t.string  "name",       limit: 40,                                         null: false
    t.integer "value_type", limit: 4,                                          null: false
    t.boolean "is_custom",  limit: 1,                          default: true,  null: false
    t.integer "width",      limit: 4,                                          null: false
    t.decimal "ordering",              precision: 9, scale: 5
    t.boolean "show",       limit: 1,                          default: false, null: false
  end

  add_index "story_attributes", ["project_id"], name: "index_story_attributes_on_project_id", using: :btree

  create_table "story_values", force: :cascade do |t|
    t.integer "story_id",           limit: 4,     null: false
    t.integer "story_attribute_id", limit: 4,     null: false
    t.text    "value",              limit: 65535
  end

  add_index "story_values", ["story_id"], name: "index_story_values_on_story_id", using: :btree

  create_table "survey_mappings", force: :cascade do |t|
    t.integer "survey_id", limit: 4, null: false
    t.integer "story_id",  limit: 4
    t.integer "priority",  limit: 4
  end

  add_index "survey_mappings", ["survey_id"], name: "index_survey_mappings_on_survey_id", using: :btree

  create_table "surveys", force: :cascade do |t|
    t.integer  "project_id", limit: 4,                   null: false
    t.string   "email",      limit: 100,                 null: false
    t.boolean  "excluded",   limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 80,                  null: false
    t.string   "company",    limit: 80
  end

  add_index "surveys", ["project_id"], name: "index_surveys_on_project_id", using: :btree

  create_table "systems", force: :cascade do |t|
    t.text "license_agreement", limit: 65535
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "name",           limit: 250,                                       null: false
    t.text     "description",    limit: 65535
    t.decimal  "effort",                       precision: 7, scale: 2
    t.integer  "status_code",    limit: 4,                             default: 0, null: false
    t.integer  "individual_id",  limit: 4
    t.integer  "story_id",       limit: 4
    t.text     "reason_blocked", limit: 65535
    t.decimal  "priority",                     precision: 9, scale: 5
    t.decimal  "estimate",                     precision: 7, scale: 2
    t.decimal  "actual",                       precision: 7, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "in_progress_at"
    t.datetime "done_at"
  end

  add_index "tasks", ["story_id"], name: "index_tasks_on_story_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",        limit: 40,    null: false
    t.text     "description", limit: 65535
    t.integer  "project_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "teams", ["project_id"], name: "index_teams_on_project_id", using: :btree

end

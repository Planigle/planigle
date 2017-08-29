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

ActiveRecord::Schema.define(version: 20170826150000) do

  create_table "audits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.string   "auditable_name"
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes",  limit: 65535
    t.integer  "version",                        default: 0
    t.datetime "created_at"
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.integer  "association_id"
    t.string   "association_type"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["project_id"], name: "project_index", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "story_id",                    null: false
    t.integer  "individual_id",               null: false
    t.integer  "ordering",                    null: false
    t.text     "message",       limit: 65535, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                        limit: 40, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.date     "premium_expiry"
    t.integer  "premium_limit"
    t.datetime "last_notified_of_expiration"
  end

  create_table "criteria", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text    "description", limit: 65535,                                     null: false
    t.integer "status_code",                                       default: 0, null: false
    t.integer "story_id"
    t.decimal "priority",                  precision: 9, scale: 5
    t.index ["story_id"], name: "index_criteria_on_story_id", using: :btree
  end

  create_table "errors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "individual_id",              null: false
    t.datetime "time",                       null: false
    t.string   "message",       limit: 256,  null: false
    t.string   "stack_trace",   limit: 8192, null: false
  end

  create_table "individual_story_attributes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "individual_id",                                              null: false
    t.integer "story_attribute_id",                                         null: false
    t.integer "width",                                                      null: false
    t.decimal "ordering",           precision: 9, scale: 5
    t.boolean "show",                                       default: false, null: false
  end

  create_table "individuals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "login",                     limit: 40
    t.string   "email",                     limit: 100
    t.string   "first_name",                limit: 40
    t.string   "last_name",                 limit: 40
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           limit: 40
    t.datetime "activated_at"
    t.boolean  "enabled",                               default: true
    t.integer  "role"
    t.datetime "last_login"
    t.datetime "accepted_agreement"
    t.integer  "team_id"
    t.string   "phone_number",              limit: 20
    t.integer  "notification_type",                     default: 0
    t.integer  "company_id"
    t.integer  "selected_project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "refresh_interval",                      default: 300000
    t.string   "forgot_token"
    t.datetime "forgot_token_expires_at"
    t.index ["company_id"], name: "index_individuals_on_company_id", using: :btree
    t.index ["remember_token"], name: "index_individuals_on_remember_token", using: :btree
  end

  create_table "individuals_projects", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "project_id"
    t.integer "individual_id"
    t.index ["individual_id"], name: "index_individuals_projects_on_individual_id", using: :btree
    t.index ["project_id"], name: "index_individuals_projects_on_project_id", using: :btree
  end

  create_table "iteration_story_totals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "iteration_id"
    t.date    "date"
    t.integer "team_id"
    t.decimal "created",      precision: 7, scale: 2
    t.decimal "in_progress",  precision: 7, scale: 2
    t.decimal "blocked",      precision: 7, scale: 2
    t.decimal "done",         precision: 7, scale: 2
  end

  create_table "iteration_totals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "iteration_id"
    t.date    "date"
    t.decimal "created",      precision: 7, scale: 2
    t.decimal "in_progress",  precision: 7, scale: 2
    t.decimal "done",         precision: 7, scale: 2
    t.integer "team_id"
    t.decimal "blocked",      precision: 7, scale: 2
  end

  create_table "iteration_velocities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "iteration_id"
    t.integer "team_id"
    t.decimal "attempted",    precision: 7, scale: 2
    t.decimal "completed",    precision: 7, scale: 2
    t.decimal "lead_time",    precision: 7, scale: 2
    t.decimal "cycle_time",   precision: 7, scale: 2
    t.integer "num_stories"
  end

  create_table "iterations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.date     "start"
    t.integer  "project_id"
    t.text     "retrospective_results", limit: 65535
    t.date     "finish",                                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "notable",               limit: 40,    default: ""
    t.index ["project_id"], name: "index_iterations_on_project_id", using: :btree
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",                        limit: 40,                    null: false
    t.text     "description",                 limit: 65535
    t.string   "survey_key",                  limit: 40,                    null: false
    t.integer  "survey_mode",                                               null: false
    t.integer  "company_id"
    t.boolean  "track_actuals",                             default: false, null: false
    t.datetime "last_notified_of_inactivity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_projects_on_company_id", using: :btree
    t.index ["survey_key"], name: "index_projects_on_survey_key", unique: true, using: :btree
  end

  create_table "release_totals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "release_id"
    t.integer "team_id"
    t.date    "date"
    t.decimal "created",     precision: 7, scale: 2
    t.decimal "in_progress", precision: 7, scale: 2
    t.decimal "done",        precision: 7, scale: 2
    t.decimal "blocked",     precision: 7, scale: 2
  end

  create_table "releases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "project_id"
    t.string   "name"
    t.date     "start"
    t.date     "finish"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["project_id"], name: "index_releases_on_project_id", using: :btree
  end

  create_table "schema_info", id: false, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "version"
  end

  create_table "stories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",           limit: 250,                                        null: false
    t.text     "description",    limit: 65535
    t.decimal  "effort",                       precision: 7,  scale: 2
    t.integer  "status_code",                                           default: 0, null: false
    t.decimal  "priority",                     precision: 11, scale: 5
    t.integer  "iteration_id"
    t.integer  "individual_id"
    t.integer  "project_id"
    t.boolean  "is_public"
    t.decimal  "user_priority",                precision: 7,  scale: 3
    t.integer  "release_id"
    t.integer  "team_id"
    t.text     "reason_blocked", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "story_id"
    t.datetime "in_progress_at"
    t.datetime "done_at"
    t.index ["project_id", "iteration_id"], name: "index_stories_on_project_id_and_iteration_id", using: :btree
    t.index ["project_id", "status_code"], name: "index_stories_on_project_id_and_status_code", using: :btree
    t.index ["story_id"], name: "index_stories_on_story_id", using: :btree
  end

  create_table "story_attribute_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "story_attribute_id"
    t.integer "release_id"
    t.text    "value",              limit: 255
    t.index ["story_attribute_id"], name: "index_story_attribute_values_on_story_attribute_id", using: :btree
  end

  create_table "story_attributes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "project_id",                                                    null: false
    t.string  "name",       limit: 40,                                         null: false
    t.integer "value_type",                                                    null: false
    t.boolean "is_custom",                                     default: true,  null: false
    t.integer "width",                                                         null: false
    t.decimal "ordering",              precision: 9, scale: 5
    t.boolean "show",                                          default: false, null: false
    t.index ["project_id"], name: "index_story_attributes_on_project_id", using: :btree
  end

  create_table "story_values", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "story_id",                         null: false
    t.integer "story_attribute_id",               null: false
    t.text    "value",              limit: 65535
    t.index ["story_id"], name: "index_story_values_on_story_id", using: :btree
  end

  create_table "survey_mappings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "survey_id", null: false
    t.integer "story_id"
    t.integer "priority"
    t.index ["survey_id"], name: "index_survey_mappings_on_survey_id", using: :btree
  end

  create_table "surveys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "project_id",                             null: false
    t.string   "email",      limit: 100,                 null: false
    t.boolean  "excluded",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 80,                  null: false
    t.string   "company",    limit: 80
    t.index ["project_id"], name: "index_surveys_on_project_id", using: :btree
  end

  create_table "systems", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "license_agreement", limit: 65535
  end

  create_table "tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",           limit: 250,                                       null: false
    t.text     "description",    limit: 65535
    t.decimal  "effort",                       precision: 7, scale: 2
    t.integer  "status_code",                                          default: 0, null: false
    t.integer  "individual_id"
    t.integer  "story_id"
    t.text     "reason_blocked", limit: 65535
    t.decimal  "priority",                     precision: 9, scale: 5
    t.decimal  "estimate",                     precision: 7, scale: 2
    t.decimal  "actual",                       precision: 7, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.datetime "in_progress_at"
    t.datetime "done_at"
    t.index ["story_id"], name: "index_tasks_on_story_id", using: :btree
  end

  create_table "teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name",        limit: 40,    null: false
    t.text     "description", limit: 65535
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["project_id"], name: "index_teams_on_project_id", using: :btree
  end

end

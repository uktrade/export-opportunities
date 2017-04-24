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

ActiveRecord::Schema.define(version: 20170321143245) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "uuid-ossp"

  create_table "contacts", force: :cascade do |t|
    t.uuid   "opportunity_id", null: false
    t.string "name",           null: false
    t.string "email",          null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "slug",                 null: false
    t.string "name",                 null: false
    t.string "exporting_guide_path"
  end

  add_index "countries", ["slug"], name: "index_countries_on_slug", unique: true, using: :btree

  create_table "countries_opportunities", id: false, force: :cascade do |t|
    t.integer "country_id",     null: false
    t.uuid    "opportunity_id", null: false
  end

  add_index "countries_opportunities", ["country_id"], name: "index_countries_opportunities_on_country_id", using: :btree
  add_index "countries_opportunities", ["opportunity_id"], name: "index_countries_opportunities_on_opportunity_id", using: :btree

  create_table "countries_subscriptions", id: false, force: :cascade do |t|
    t.integer "country_id",      null: false
    t.uuid    "subscription_id"
  end

  add_index "countries_subscriptions", ["country_id"], name: "index_countries_subscriptions_on_country_id", using: :btree

  create_table "editors", force: :cascade do |t|
    t.integer  "wordpress_id"
    t.string   "username"
    t.string   "encrypted_password",                 null: false
    t.string   "email",                              null: false
    t.string   "name",                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "role",                   default: 0, null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "deactivated_at"
    t.integer  "service_provider_id"
    t.integer  "failed_attempts",        default: 0, null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "editors", ["confirmation_token"], name: "index_editors_on_confirmation_token", unique: true, using: :btree
  add_index "editors", ["email"], name: "index_editors_on_email", unique: true, using: :btree
  add_index "editors", ["reset_password_token"], name: "index_editors_on_reset_password_token", unique: true, using: :btree
  add_index "editors", ["service_provider_id"], name: "index_editors_on_service_provider_id", using: :btree
  add_index "editors", ["unlock_token"], name: "index_editors_on_unlock_token", unique: true, using: :btree

  create_table "enquiries", force: :cascade do |t|
    t.string   "first_name",                           null: false
    t.string   "last_name",                            null: false
    t.string   "legacy_email_address"
    t.string   "company_telephone",                    null: false
    t.string   "company_name",                         null: false
    t.string   "company_address"
    t.string   "company_house_number"
    t.string   "company_postcode"
    t.string   "company_url"
    t.string   "existing_exporter",                    null: false
    t.string   "company_sector",                       null: false
    t.text     "company_explanation",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "opportunity_id"
    t.boolean  "data_protection",      default: false
    t.uuid     "user_id",                              null: false
  end

  add_index "enquiries", ["legacy_email_address"], name: "index_enquiries_on_legacy_email_address", using: :btree
  add_index "enquiries", ["user_id"], name: "index_enquiries_on_user_id", using: :btree

  create_table "enquiry_feedbacks", force: :cascade do |t|
    t.integer  "enquiry_id"
    t.datetime "responded_at"
    t.integer  "initial_response", default: 0, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "enquiry_feedbacks", ["enquiry_id"], name: "index_enquiry_feedbacks_on_enquiry_id", unique: true, using: :btree

  create_table "feedback_opt_outs", force: :cascade do |t|
    t.string   "legacy_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "user_id",      null: false
  end

  add_index "feedback_opt_outs", ["legacy_email"], name: "index_feedback_opt_outs_on_legacy_email", unique: true, using: :btree
  add_index "feedback_opt_outs", ["user_id"], name: "index_feedback_opt_outs_on_user_id", using: :btree

  create_table "opportunities", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "title"
    t.string   "slug"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "status",              null: false
    t.text     "teaser"
    t.date     "response_due_on"
    t.text     "description"
    t.integer  "service_provider_id"
    t.integer  "author_id",           null: false
    t.integer  "enquiries_count"
    t.tsvector "tsv"
    t.datetime "first_published_at"
  end

  add_index "opportunities", ["service_provider_id"], name: "index_opportunities_on_service_provider_id", using: :btree
  add_index "opportunities", ["slug"], name: "index_opportunities_on_slug", unique: true, using: :btree
  add_index "opportunities", ["tsv"], name: "index_opportunities_on_tsv", using: :gin

  create_table "opportunities_sectors", id: false, force: :cascade do |t|
    t.uuid    "opportunity_id", null: false
    t.integer "sector_id",      null: false
  end

  add_index "opportunities_sectors", ["opportunity_id"], name: "index_opportunities_sectors_on_opportunity_id", using: :btree
  add_index "opportunities_sectors", ["sector_id"], name: "index_opportunities_sectors_on_sector_id", using: :btree

  create_table "opportunities_types", id: false, force: :cascade do |t|
    t.uuid    "opportunity_id", null: false
    t.integer "type_id",        null: false
  end

  add_index "opportunities_types", ["opportunity_id"], name: "index_opportunities_types_on_opportunity_id", using: :btree
  add_index "opportunities_types", ["type_id"], name: "index_opportunities_types_on_type_id", using: :btree

  create_table "opportunities_values", id: false, force: :cascade do |t|
    t.uuid    "opportunity_id", null: false
    t.integer "value_id",       null: false
  end

  add_index "opportunities_values", ["opportunity_id"], name: "index_opportunities_values_on_opportunity_id", using: :btree
  add_index "opportunities_values", ["value_id"], name: "index_opportunities_values_on_value_id", using: :btree

  create_table "opportunity_comments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "message",        null: false
    t.uuid     "opportunity_id", null: false
    t.integer  "author_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "opportunity_comments", ["author_id"], name: "index_opportunity_comments_on_author_id", using: :btree
  add_index "opportunity_comments", ["opportunity_id"], name: "index_opportunity_comments_on_opportunity_id", using: :btree

  create_table "opportunity_versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.uuid     "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "opportunity_versions", ["item_type", "item_id"], name: "index_opportunity_versions_on_item_type_and_item_id", using: :btree

  create_table "pending_subscriptions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.text     "query_params"
    t.uuid     "subscription_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pending_subscriptions", ["subscription_id"], name: "index_pending_subscriptions_on_subscription_id", using: :btree

  create_table "sectors", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
  end

  add_index "sectors", ["slug"], name: "index_sectors_on_slug", unique: true, using: :btree

  create_table "sectors_subscriptions", id: false, force: :cascade do |t|
    t.integer "sector_id",       null: false
    t.uuid    "subscription_id"
  end

  add_index "sectors_subscriptions", ["sector_id"], name: "index_sectors_subscriptions_on_sector_id", using: :btree

  create_table "service_providers", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "subscription_notifications", force: :cascade do |t|
    t.uuid     "opportunity_id"
    t.uuid     "subscription_id"
    t.boolean  "sent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscription_notifications", ["opportunity_id"], name: "index_subscription_notifications_on_opportunity_id", using: :btree
  add_index "subscription_notifications", ["subscription_id"], name: "index_subscription_notifications_on_subscription_id", using: :btree

  create_table "subscriptions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "legacy_email"
    t.string   "search_term"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "unsubscribe_reason"
    t.datetime "unsubscribed_at"
    t.uuid     "user_id",              null: false
  end

  add_index "subscriptions", ["confirmation_token"], name: "index_subscriptions_on_confirmation_token", unique: true, using: :btree
  add_index "subscriptions", ["legacy_email"], name: "index_subscriptions_on_legacy_email", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "subscriptions_types", id: false, force: :cascade do |t|
    t.integer "type_id",         null: false
    t.uuid    "subscription_id"
  end

  add_index "subscriptions_types", ["type_id"], name: "index_subscriptions_types_on_type_id", using: :btree

  create_table "subscriptions_values", id: false, force: :cascade do |t|
    t.integer "value_id",        null: false
    t.uuid    "subscription_id"
  end

  add_index "subscriptions_values", ["value_id"], name: "index_subscriptions_values_on_value_id", using: :btree

  create_table "types", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
  end

  add_index "types", ["slug"], name: "index_types_on_slug", unique: true, using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "email",               default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["id"], name: "index_users_on_id", using: :btree

  create_table "values", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
  end

  add_index "values", ["slug"], name: "index_values_on_slug", unique: true, using: :btree

  add_foreign_key "editors", "service_providers"
  add_foreign_key "enquiries", "users"
  add_foreign_key "enquiry_feedbacks", "enquiries"
  add_foreign_key "feedback_opt_outs", "users"
  add_foreign_key "subscriptions", "users"
  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute(<<-TRIGGERSQL)
CREATE OR REPLACE FUNCTION pg_catalog.tsvector_update_trigger()
 RETURNS trigger
 LANGUAGE internal
 PARALLEL SAFE
AS $function$tsvector_update_trigger_byid$function$
  TRIGGERSQL

  create_trigger("opportunities_after_insert_update_row_tr", :generated => true, :compatibility => 1).
      on("opportunities").
      before(:insert, :update).
      for_each(:row).
      nowrap(true) do
    "tsvector_update_trigger(tsv, 'pg_catalog.english', title, teaser, description);"
  end

end

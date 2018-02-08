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

ActiveRecord::Schema.define(version: 20180207034737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind"
  end

  create_table "cert_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dim_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "edition_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_groups", force: :cascade do |t|
    t.string "classifiable_type"
    t.bigint "classifiable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_field_id"
    t.index ["classifiable_type", "classifiable_id"], name: "index_field_groups_on_classifiable_type_and_classifiable_id"
    t.index ["item_field_id"], name: "index_field_groups_on_item_field_id"
  end

  create_table "field_values", force: :cascade do |t|
    t.string "name"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_fields", force: :cascade do |t|
    t.string "name"
    t.string "field_type"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sign_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "type_groups", force: :cascade do |t|
    t.string "classifiable_type"
    t.bigint "classifiable_id"
    t.string "typeable_type"
    t.bigint "typeable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classifiable_type", "classifiable_id"], name: "index_type_groups_on_classifiable_type_and_classifiable_id"
    t.index ["typeable_type", "typeable_id"], name: "index_type_groups_on_typeable_type_and_typeable_id"
  end

  create_table "value_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

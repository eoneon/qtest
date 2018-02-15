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

ActiveRecord::Schema.define(version: 20180215034743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "categories", force: :cascade do |t|
    t.string "name"
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
    t.bigint "category_id"
    t.hstore "properties"
    t.index ["category_id"], name: "index_edition_types_on_category_id"
  end

  create_table "field_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_field_id"
    t.bigint "category_id"
    t.integer "sort"
    t.index ["category_id"], name: "index_field_groups_on_category_id"
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
    t.bigint "category_id"
    t.hstore "properties"
    t.index ["category_id"], name: "index_item_types_on_category_id"
    t.index ["properties"], name: "index_item_types_on_properties", using: :gist
  end

  create_table "items", force: :cascade do |t|
    t.hstore "properties"
    t.bigint "item_type_id"
    t.bigint "edition_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sku"
    t.index ["edition_type_id"], name: "index_items_on_edition_type_id"
    t.index ["item_type_id"], name: "index_items_on_item_type_id"
    t.index ["properties"], name: "index_items_on_properties", using: :gist
  end

  create_table "sign_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.hstore "properties"
    t.bigint "category_id"
    t.index ["category_id"], name: "index_sign_types_on_category_id"
  end

  create_table "value_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_field_id"
    t.bigint "field_value_id"
    t.index ["field_value_id"], name: "index_value_groups_on_field_value_id"
    t.index ["item_field_id"], name: "index_value_groups_on_item_field_id"
  end

end

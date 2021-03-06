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

ActiveRecord::Schema.define(version: 20150514115246) do

  create_table "bag_items", force: true do |t|
    t.string   "name",                    null: false
    t.string   "url_dp",                  null: false
    t.integer  "width",                   null: false
    t.integer  "height",                  null: false
    t.integer  "depth"
    t.integer  "price",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url"
    t.integer  "long_side",   default: 0, null: false
    t.integer  "middle_side", default: 0, null: false
    t.integer  "short_side",  default: 0, null: false
  end

  add_index "bag_items", ["long_side"], name: "index_bag_items_on_long_side"
  add_index "bag_items", ["middle_side"], name: "index_bag_items_on_middle_side"
  add_index "bag_items", ["price"], name: "index_bag_items_on_price"
  add_index "bag_items", ["short_side"], name: "index_bag_items_on_short_side"
  add_index "bag_items", ["url_dp"], name: "index_bag_items_on_url_dp"

  create_table "bag_items_bag_tags", id: false, force: true do |t|
    t.integer "bag_item_id", null: false
    t.integer "bag_tag_id",  null: false
  end

  create_table "bag_tags", force: true do |t|
    t.string   "name",                   null: false
    t.integer  "tree_depth", default: 0, null: false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bag_tags", ["parent_id"], name: "index_bag_tags_on_parent_id"

  create_table "crawl_bag_detail_managers", force: true do |t|
    t.text     "url"
    t.integer  "bag_tag_id"
    t.boolean  "done_flag",  default: false, null: false
    t.boolean  "error_flag", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "crawl_bag_detail_managers", ["bag_tag_id"], name: "index_crawl_bag_detail_managers_on_bag_tag_id"

  create_table "crawl_bag_page_managers", force: true do |t|
    t.integer  "bag_tag_id"
    t.text     "url"
    t.integer  "progress_page", default: 1,     null: false
    t.boolean  "done_flag",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "progress_item", default: 0,     null: false
  end

  add_index "crawl_bag_page_managers", ["bag_tag_id"], name: "index_crawl_bag_page_managers_on_bag_tag_id"

  create_table "device_brands", force: true do |t|
    t.string   "name",                      null: false
    t.integer  "tree_depth", default: 0,    null: false
    t.boolean  "leaf_flag",  default: true, null: false
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_brands", ["parent_id"], name: "index_device_brands_on_parent_id"

  create_table "device_items", force: true do |t|
    t.string   "name",                        null: false
    t.integer  "width",                       null: false
    t.integer  "height",                      null: false
    t.integer  "depth"
    t.integer  "device_brand_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "long_side",       default: 0, null: false
    t.integer  "middle_side",     default: 0, null: false
    t.integer  "short_side",      default: 0, null: false
  end

  add_index "device_items", ["device_brand_id"], name: "index_device_items_on_device_brand_id"
  add_index "device_items", ["long_side"], name: "index_device_items_on_long_side"
  add_index "device_items", ["middle_side"], name: "index_device_items_on_middle_side"
  add_index "device_items", ["short_side"], name: "index_device_items_on_short_side"

end

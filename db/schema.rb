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

ActiveRecord::Schema.define(version: 20170410163930) do

  create_table "books", force: :cascade do |t|
    t.decimal  "price"
    t.string   "number"
    t.string   "smoking"
    t.string   "room_type"
    t.integer  "hotel_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "occupancy_a"
    t.integer  "team_id"
    t.integer  "occupancy_c"
    t.boolean  "paid_status"
    t.index ["hotel_id"], name: "index_books_on_hotel_id"
    t.index ["team_id"], name: "index_books_on_team_id"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "carts", force: :cascade do |t|
    t.decimal  "price"
    t.string   "number"
    t.string   "smoking"
    t.string   "room_type"
    t.integer  "hotel_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "occupancy_a"
    t.integer  "team_id"
    t.integer  "occupancy_c"
    t.index ["hotel_id"], name: "index_carts_on_hotel_id"
    t.index ["team_id"], name: "index_carts_on_team_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "guest_type"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "compoundname"
    t.integer  "team_id"
    t.index ["team_id"], name: "index_guests_on_team_id"
    t.index ["user_id", "compoundname"], name: "index_guests_on_user_id_and_compoundname"
    t.index ["user_id"], name: "index_guests_on_user_id"
  end

  create_table "hotels", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.decimal  "lat"
    t.decimal  "long"
    t.string   "phone"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "image"
    t.string   "description"
    t.string   "website"
    t.decimal  "tax"
    t.string   "checkin"
    t.string   "checkout"
    t.decimal  "resortFee"
  end

  create_table "reservations", force: :cascade do |t|
    t.decimal  "total"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.decimal  "price"
    t.string   "number"
    t.string   "smoking"
    t.string   "room_type"
    t.integer  "hotel_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "occupancy_a"
    t.integer  "occupancy_c"
    t.string   "description"
    t.index ["hotel_id"], name: "index_rooms_on_hotel_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "conf_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "fee_status"
    t.decimal  "balance"
    t.boolean  "exempt"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "total"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "transaction_type"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "team"
    t.boolean  "fee_status"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "team_id"
    t.decimal  "user_balance"
    t.index ["team_id"], name: "index_users_on_team_id"
  end

end

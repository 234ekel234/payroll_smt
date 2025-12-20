# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_20_073517) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "employees", force: :cascade do |t|
    t.decimal "allowance_per_day"
    t.decimal "basic_rate"
    t.time "break_end"
    t.time "break_start"
    t.string "company"
    t.datetime "created_at", null: false
    t.boolean "landbank_atm"
    t.string "name"
    t.string "person_id"
    t.text "rest_days", default: ["Sat", "Sun"], array: true
    t.string "schedule"
    t.time "shift_end"
    t.time "shift_start"
    t.string "status_of_employment"
    t.datetime "updated_at", null: false
    t.text "work_days", default: ["Mon", "Tue", "Wed", "Thu", "Fri"], array: true
    t.index ["person_id"], name: "index_employees_on_person_id", unique: true
  end
end

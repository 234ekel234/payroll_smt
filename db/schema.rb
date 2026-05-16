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

ActiveRecord::Schema[8.1].define(version: 2026_05_17_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "daily_time_records", force: :cascade do |t|
    t.string "abnormal_situation"
    t.datetime "clock_in"
    t.datetime "clock_out"
    t.datetime "created_at", null: false
    t.date "date"
    t.bigint "employee_id", null: false
    t.integer "holiday_minutes"
    t.integer "late_minutes"
    t.integer "night_diff_minutes"
    t.integer "overtime_minutes"
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_daily_time_records_on_employee_id"
  end

  create_table "deductions", force: :cascade do |t|
    t.boolean "active"
    t.decimal "amount", precision: 12, scale: 2
    t.integer "amount_type"
    t.string "applies_to"
    t.string "category"
    t.datetime "created_at", null: false
    t.string "deduction_type"
    t.integer "employee_group_id"
    t.string "name"
    t.text "notes"
    t.datetime "updated_at", null: false
  end

  create_table "employee_deductions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "deduction_id", null: false
    t.bigint "employee_id", null: false
    t.datetime "updated_at", null: false
    t.index ["deduction_id"], name: "index_employee_deductions_on_deduction_id"
    t.index ["employee_id"], name: "index_employee_deductions_on_employee_id"
  end

  create_table "employees", force: :cascade do |t|
    t.boolean "active", default: true
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
    t.bigint "shift_id"
    t.time "shift_start"
    t.string "status_of_employment"
    t.datetime "updated_at", null: false
    t.text "work_days", default: ["Mon", "Tue", "Wed", "Thu", "Fri"], array: true
    t.index ["person_id"], name: "index_employees_on_person_id", unique: true
    t.index ["shift_id"], name: "index_employees_on_shift_id"
  end

  create_table "gov_deduction_brackets", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.integer "deduction_type", null: false
    t.decimal "range_max", precision: 12, scale: 2, null: false
    t.decimal "range_min", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "holidays", force: :cascade do |t|
    t.string "applies_to"
    t.datetime "created_at", null: false
    t.date "date"
    t.string "holiday_type"
    t.string "name"
    t.text "notes"
    t.datetime "updated_at", null: false
  end

  create_table "pay_multipliers", force: :cascade do |t|
    t.decimal "base_multiplier"
    t.string "code"
    t.datetime "created_at", null: false
    t.string "holiday_type"
    t.string "name"
    t.boolean "overtime"
    t.boolean "rest_day"
    t.datetime "updated_at", null: false
  end

  create_table "payroll_deductions", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.bigint "deduction_id"
    t.string "note"
    t.bigint "payroll_id", null: false
    t.datetime "updated_at", null: false
    t.index ["deduction_id"], name: "index_payroll_deductions_on_deduction_id"
    t.index ["payroll_id"], name: "index_payroll_deductions_on_payroll_id"
  end

  create_table "payrolls", force: :cascade do |t|
    t.decimal "absent_holiday_pay", precision: 10, scale: 2, default: "0.0"
    t.decimal "allowance"
    t.decimal "basic_pay"
    t.decimal "cash_advance"
    t.datetime "created_at", null: false
    t.decimal "daily_rate"
    t.integer "days_worked"
    t.bigint "employee_id", null: false
    t.date "end_date"
    t.decimal "groceries_deduction"
    t.decimal "gross_pay", precision: 12, scale: 2
    t.decimal "hdmf_amount"
    t.decimal "hdmf_loan"
    t.decimal "holiday_pay"
    t.decimal "late_ut_amount"
    t.decimal "materials_deduction"
    t.decimal "net_pay", precision: 12, scale: 2
    t.decimal "night_diff_pay"
    t.decimal "overtime_pay"
    t.decimal "phic_amount"
    t.datetime "processed_at"
    t.decimal "rest_day_pay"
    t.decimal "rice_deduction"
    t.decimal "sss_amount"
    t.decimal "sss_loan"
    t.date "start_date"
    t.string "status"
    t.decimal "total_deductions", precision: 12, scale: 2
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_payrolls_on_employee_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.time "break_end"
    t.time "break_start"
    t.datetime "created_at", null: false
    t.string "name"
    t.time "shift_end"
    t.time "shift_start"
    t.datetime "updated_at", null: false
  end

  create_table "time_slices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "daily_time_record_id", null: false
    t.datetime "end_time"
    t.boolean "holiday"
    t.integer "late", default: 0, null: false
    t.integer "minutes"
    t.string "multiplier_code"
    t.string "multiplier_name"
    t.decimal "multiplier_percent", precision: 5, scale: 2
    t.boolean "night_diff"
    t.boolean "overtime", default: false, null: false
    t.decimal "pay", precision: 12, scale: 2
    t.boolean "rest_day"
    t.datetime "start_time"
    t.datetime "updated_at", null: false
    t.index ["daily_time_record_id"], name: "index_time_slices_on_daily_time_record_id"
  end

  add_foreign_key "daily_time_records", "employees"
  add_foreign_key "employee_deductions", "deductions"
  add_foreign_key "employee_deductions", "employees"
  add_foreign_key "employees", "shifts"
  add_foreign_key "payroll_deductions", "deductions"
  add_foreign_key "payroll_deductions", "payrolls"
  add_foreign_key "payrolls", "employees"
  add_foreign_key "time_slices", "daily_time_records"
end

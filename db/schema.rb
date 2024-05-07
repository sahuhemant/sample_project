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

ActiveRecord::Schema[7.0].define(version: 2024_05_07_155522) do
  create_table "employees", primary_key: "employee_id", id: :string, force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "mobile_number"
    t.date "date_of_birth"
    t.date "date_of_joining"
    t.string "account_number"
    t.string "ifsc_code"
    t.string "bank_name"
    t.boolean "pf_opt"
    t.boolean "tds_deduction"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employees_on_employee_id"
  end

  create_table "leave_requests", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.integer "leave_type"
    t.text "reason"
    t.integer "status"
    t.datetime "deleted_at"
    t.integer "session_type"
    t.float "total_days"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employee_id", null: false
    t.index ["employee_id"], name: "index_leave_requests_on_employee_id"
  end

  add_foreign_key "leave_requests", "employees", primary_key: "employee_id"
end

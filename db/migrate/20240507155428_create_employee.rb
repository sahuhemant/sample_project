class CreateEmployee < ActiveRecord::Migration[7.0]
  def change
    create_table :employees, id: false , if_not_exists: true do |t|
      t.string "employee_id", primary_key: true, index: true
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
      t.integer :status

      t.timestamps
    end
  end
end

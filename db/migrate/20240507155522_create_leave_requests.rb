class CreateLeaveRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :leave_requests do |t|
      t.date       :start_date
      t.date       :end_date
      t.integer    :leave_type
      t.text       :reason
      t.integer    :status, default: 'pending'
      t.datetime   :deleted_at
      t.integer    :session_type
      t.float      :total_days

      t.timestamps
    end
    add_reference :leave_requests, :employee,
      type: :string, # default is bigint
      null: false,
      foreign_key: { primary_key: "employee_id" },
      index: true
  end
end

# # frozen_string_literal: true

class Employee < ApplicationRecord
#     audited
#     self.primary_key = 'employee_id'
#     has_one :seperation, primary_key: "employee_id"
#     has_many :payrolls, primary_key: "employee_id", dependent: :destroy
#     has_many :leave_requests, primary_key: "employee_id", dependent: :destroy
#     has_many :revision_salaries, primary_key: "employee_id", dependent: :destroy
#     # validates :employee_id, presence: true, uniqueness: true
#     after_update :recalculate_payroll_on_pf
  
#     scope :ex_employee, -> { joins(:seperation).where('leaving_date < ?', Date.today) }
#     scope :current_employee, -> { all.where.not(employee_id: Employee.ex_employee.ids) }
#     scope :on_going_notice_employee, -> { joins(:seperation).where('seperations.leaving_date': Date.today.beginning_of_month..Date.today.end_of_month) }
#     scope :current_month_on_boarding, -> { where(date_of_joining: Date.today.beginning_of_month..Date.today.end_of_month)}
#     scope :pf_holders, -> { where(pf_opt: true)}
#     scope :tds_holders, -> { where(tds_deduction: true)}
  
#     def recalculate_payroll_on_pf
#       if pf_opt_changed?
#         payroll = payrolls.where(month: Date.today.strftime("%B"), year: Date.today.year)
#         month = Date::MONTHNAMES.index(payroll.month)
#         year = payroll.year
#         payroll.update(total_salary: total_salary(month, year))
#       end
#     end
  
#     def self.import_employee_sheet(file)
#       xlsx = Roo::Spreadsheet.open(file)
#       xlsx.parse(email: "email", full_name: "full_name", account_number: "account_number",ifsc_code: "ifsc_code", bank_name: "bank_name", mobile_number: "mobile_number", date_of_birth: "date_of_birth", date_of_joining: "date_of_joining", employee_id: "shriffle_id", current_salary: "current_salary", current_salary_effective_date: "current_salary_effective_date", sepration_mode: "sepration_mode", sepration_date: "sepration_date").each do |value|
#         employee = Employee.find_by(employee_id: value[:employee_id])
#         unless employee.present?
#           employee = Employee.create(email: value[:email], full_name: value[:full_name], account_number: value[:account_number],ifsc_code: value[:ifsc_code], bank_name: value[:bank_name], mobile_number: value[:mobile_number], date_of_birth: value[:date_of_birth], date_of_joining: value[:date_of_joining], employee_id: value[:employee_id])
#           RevisionSalary.create(revision_salary: value[:current_salary],
#             effective_date: value[:date_of_joining], employee_id: employee.employee_id)
#         end
  
#         if employee.present?
#           last_revision_salary = employee.revision_salaries.last&.revision_salary.to_i
#           unless last_revision_salary.eql?(value[:current_salary].to_i)
#             revision_salary = employee.revision_salaries.find_by(revision_salary: value[:current_salary])
#             employee.revision_salaries.create(revision_salary: value[:current_salary],
#               previous_salary: last_revision_salary,
#               effective_date: value[:current_salary_effective_date]) unless revision_salary.present?
#           end
#           Seperation.find_or_create_by(seperation_mode: value[:sepration_mode],  resignation_submitted_on: value[:sepration_date].to_date, seperation_submit_date: value[:sepration_date].to_date, employee_id: value[:employee_id]) if value[:sepration_mode].present? && value[:sepration_mode].present?
#         end
#       end
#     end
  
#     #Salary Enet Sheet------------------------------------------
#     def self.salary_data_for_sheet(month, year, transaction_date)
#       Employee.particular_month_employees(month, year).reject { |emp| emp.enet_opt == false }.map do |emp|
#         total_salary = emp.total_salary(month, year)
#         ['N', nil, emp.account_number, total_salary.to_i, emp.full_name, nil, nil, nil, nil, nil, nil, nil, "#{Date::MONTHNAMES[month]} salary", "#{Date::MONTHNAMES[month]} salary", nil, nil, nil, nil, nil, nil, nil, "#{transaction_date.to_time.strftime("%d/%m/%Y")}", nil, emp.ifsc_code, emp.bank_name, nil, emp.email]
#       end
#     end
  
#     #Salary Calculation for Salary check sheet-----------------------------
  
#     def calculated_salary_for_salary_check_sheet(month, year)
#       return 0 unless date_of_joining <= Date.new(year, month, -1)
#      @salary_effective_date = revision_salaries.order(effective_date: "desc").find { |date| date.effective_date <= Date.new(year,month).end_of_month }.effective_date
#         # @salary_effective_date = revision_salaries.last.effective_date
#       if @salary_effective_date.month.eql?(month) && @salary_effective_date.year.eql?(year)
#         working_amount_increment_month_for_salary_check(month, year)
#       else
#         working_amount_for_salary_check(month, year)
#       end
#     end
  
#     def self.check_salary_data_for_sheet(month, year)
#       Employee.particular_month_employees(month, year).order(:full_name).map do |emp|
#         begin
#           payroll = emp.payrolls.find_by(month: Date::MONTHNAMES[month], year: year)
#           leave_data = LeaveRequest.calculate_leave_data(emp, month, year)
#           days = days_as_per_old_salary(emp, month, year)
#           working_amount = emp.calculated_salary_for_salary_check_sheet(month, year)
#           previous_salary = emp.previous_salary(month, year)
#           revised_salary = emp.revision_salary(month, year)
#           per_day_amount = (revised_salary / Time.days_in_month(month, year)).round(2)
#           leave_encash_amount = emp.leave_encashment(per_day_amount, month, year, payroll.remianing_leave_current_salary, payroll.remianing_leave_previous_first_salary)
#           gross_salary = (emp.gross_amount(month, year) + leave_encash_amount).round(2)
  
#           [
#             emp.employee_id,
#             emp.full_name,
#             revised_salary,
#             previous_salary,
#             0,
#             per_day_amount,
#             Time.days_in_month(month, year),
#             days,
#             working_amount.round(2),
#             '',
#             emp.pf_deduction(month, year).round(2),
#             emp.esic_deduction(month, year).round(2),
#             leave_data[0],
#             leave_data[1],
#             payroll.remianing_leave_current_salary,
#             payroll.remianing_leave_previous_first_salary,
#             leave_encash_amount,
#             gross_salary,
#             payroll.tds_amount,
#             payroll.one_time_deduction,
#             payroll.one_time_payment,
#             emp.esic_deduction_from_employee(month, year).round(2),
#             (emp.total_salary(month, year) + leave_encash_amount).round(),
#             '',
#             '',
#             emp.account_number,
#             emp.ifsc_code,
#             emp.bank_name,
#             emp.bank_name,
#             emp.email
#           ]
#         rescue => error
#           p "Payroll is not updated for #{month} #{year} for Employee ID #{emp.employee_id}. Please reinitialize payroll for the same."
#           nil
#         end
#       end.compact
#     end
  
#     def self.particular_month_employees(month, year)
#       month = Date::MONTHNAMES.find_index(month) if month.is_a?(String)
#       start_date_of_month = Date.new(year, month, 1)
#       end_date_of_month = start_date_of_month.end_of_month
  
#       employees = joins(:seperation)
  
#       employee_ids = employees.where('seperations.leaving_date': start_date_of_month..start_date_of_month.end_of_month).pluck(:employee_id)
  
#       employee_ids += employees.where('seperations.leaving_date > ?', start_date_of_month.end_of_month).pluck(:employee_id)
  
#       employee_ids += Employee.current_employee.pluck(:employee_id)
  
#       Employee.where(employee_id: employee_ids.flatten.uniq).includes(:revision_salaries, :payrolls, :leave_requests, :seperation)
#     end
  
#     def working_amount_for_salary_check(month, year)
#       first_date = [Date.new(year, month, 1), date_of_joining].max
#       last_date = Date.new(year, month, -1)
#       if (seperation.present? )#&& seperation.resignation_submitted_on.month <= month && seperation.resignation_submitted_on.year <= year)
#         sep_submit_date = seperation.resignation_submitted_on
#         leave_date = seperation.leaving_date
#         if (sep_submit_date.month.eql? month) && (sep_submit_date.year.eql? year)
#           last_date = sep_submit_date
#           last_date -= 1 if seperation.resigned?
  
#         # elsif sep_submit_date.month < month && sep_submit_date.year <= year
#         elsif sep_submit_date < Date.new(year, month, 1)
#           if seperation.resigned? && leave_date.present? && leave_date.month == month && leave_date.year == year
  
#             if leave_date.month == sep_submit_date.month
#               after_leaving_salary = (leave_date..sep_submit_date).count * (revision_salary(month, year) / Time.days_in_month(month, year))
#               return after_leaving_salary
#             else
#               amount = 0
#               amount += (sep_submit_date..sep_submit_date.end_of_month).count * (revision_salary(month, year) / Time.days_in_month(sep_submit_date.month, sep_submit_date.year))
#               sep_date = sep_submit_date
  
#               first_date = sep_date.next_month.beginning_of_month
#               last_date = sep_date.next_month.end_of_month
#               month = first_date.month
#               year = first_date.year
  
#               while (leave_date >= first_date && leave_date.year >= year) do
#                 if (first_date..last_date).include?(leave_date)
#                   amount += (first_date..leave_date).count * (revision_salary(month, year) / Time.days_in_month(month, year))
#                 else
#                   amount += (first_date..last_date).count * (revision_salary(month, year) / Time.days_in_month(month, year))
#                 end
#                 first_date = first_date.next_month.beginning_of_month
#                 last_date = last_date.next_month.end_of_month
#                 month = first_date.month
#                 year = first_date.year
#               end
#               return amount
#             end
#           elsif seperation.resigned? && (!leave_date.present?)
#             ((revision_salary(month, year) / Time.days_in_month(month, year)) * (first_date..last_date).count).round(2)
#           else
#             return 0
#           end
#         end
#       end
  
#       ((revision_salary(month, year) / Time.days_in_month(month, year)) * (first_date..last_date).count).round(2)
#     end
  
#     def working_amount_increment_month_for_salary_check(month, year)
#       salary_effective_date = revision_salaries.order(effective_date: "desc").find { |date| date.effective_date <= Date.new(year,month).end_of_month }.effective_date
#       days_after_increment = (Time.days_in_month(month, year) - salary_effective_date.day + 1)
#       if seperation.present? && (seperation.resignation_submitted_on.month == month) && (seperation.resignation_submitted_on.year == year)
#         days_after_increment = (salary_effective_date...seperation.resignation_submitted_on).count
#       end
#       ((previous_salary(month, year) / Time.days_in_month(month, year)) * (salary_effective_date.day - 1)) + ((revision_salary(month, year) / Time.days_in_month(month, year)) * days_after_increment).round(2)
#     end
  
  
  
#     #=========================================================#
  
#     def self.days_as_per_old_salary(emp, month, year)
#       salary_effective_date = emp.revision_salaries.order(effective_date: "desc").find { |date| date.effective_date <= Date.new(year,month).end_of_month }.effective_date
#       if (salary_effective_date.month.eql? month) && (salary_effective_date.year.eql? year)
#         salary_effective_date.day - 1
#       else
#         0
#       end
#     end
  
#     def gross_amount(month, year)
#       revised_month = @salary_effective_date.month
#       revised_year = @salary_effective_date.year
#       if revised_month.eql?(month) && revised_year.eql?(year)
#         increment_month_salary_for_salary_check(month, year).round(2)
#       else
#         normal_salary(month, year).round(2)
#       end
#     end
  
#     def normal_salary(month, year)
#       payroll = Payroll.find_by(month: Date::MONTHNAMES[month], year: year)
  
#       leave_data = LeaveRequest.calculate_leave_data(self, month, year)
  
#       comp_off_amount = (revision_salary(month, year) / Time.days_in_month(month, year)) * leave_data[1]
  
  
#       lop_leaves_deduction = (revision_salary(month, year) / Time.days_in_month(month, year)) *
#                            leave_data[0]
  
#       working_amount = working_amount_for_salary_check(month, year)
  
#       pf_and_esic_deduction = pf_deduction(month, year) + esic_deduction(month, year)
  
#       total_salary = working_amount - pf_and_esic_deduction + comp_off_amount - lop_leaves_deduction
  
#       total_salary
#     end
  
#     def total_salary(month, year)
#       set_salary_revision(month, year)
#       amount_to_add, amount_to_sub  = deduction_on_gross(month, year)
#       (gross_amount(month, year) + amount_to_add - amount_to_sub - esic_deduction_from_employee(month, year)).round(2)
#     end
  
#     def increment_month_salary_for_salary_check(month, year)
#       working_amount_increment_month = working_amount_increment_month_for_salary_check(month, year)
#       pf_and_esic_deduction = pf_deduction(month, year) + esic_deduction(month, year)
  
#       leave_data = LeaveRequest.calculate_leave_data_in_increment_month(self, month, year)
  
#       salary = working_amount_increment_month - pf_and_esic_deduction - leave_data[0] + leave_data[1]
  
#       salary
#     end
  
#     def pf_deduction(month, year)
#       if pf_opt.eql? true
#         revision_salary(month, year) >= 30000 ? (15000 * 25 / 100) : (revision_salary(month, year) / 2.0) * (25 / 100.0)
#       else
#         0
#       end
#     end
  
#     #One Time Deduction and Addition
#     def deduction_on_gross(month, year)
#       payroll = payrolls.find_by(month: Date::MONTHNAMES[month], year: year)
#       tds_amount = 0
#       one_time_payment = 0
#       one_time_deduction = 0
#       if payroll.present?
#         tds_amount = payroll.tds_amount
#         one_time_payment = payroll.one_time_payment
#         one_time_deduction = payroll.one_time_deduction
#       end
#       return one_time_payment, (tds_amount + one_time_deduction)
#     end
  
#     def esic_deduction(month, year)
#       (revision_salary(month, year) >= 21000) ? 0 : calculated_salary_for_salary_check_sheet(month, year) * 0.75 / 100
#     end
  
#     def esic_deduction_from_employee(month, year)
#       (revision_salary(month, year) >= 21000) ? 0 : gross_amount(month, year) * (3.25 / 100)
#     end
  
#     def leave_encashment(pda, month, year, leave_current_salary, leave_previous_first_salary)
#       return 0 if Date::MONTHNAMES[month] != 'December'
#       return 0 if revision_salary(month, year) == 18000
#       (pda * leave_current_salary) + (previous_salary(month, year) * leave_previous_first_salary/31).round(2)
#     end
  
#     def previous_salary(month, year)
#       return 0 unless revision_salaries.present?
#       @previous_salary ||= revision_salaries.order(effective_date: "desc").find { |date| date.effective_date <= Date.new(year,month).end_of_month }.previous_salary
#     end
  
#     def revision_salary(month, year)
#       return 0 unless revision_salaries.present?
#       @revision_salary ||= revision_salaries.order(effective_date: "desc").find { |date| date.effective_date <= Date.new(year,month).end_of_month }.revision_salary
#     end
  
#     def set_salary_revision(month, year)
#       @salary_effective_date ||= revision_salaries.order(effective_date: "desc").find { |date| date.effective_date <= Date.new(year,month).end_of_month }.effective_date
#     end
  
  end
  
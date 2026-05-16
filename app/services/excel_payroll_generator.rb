class ExcelPayrollGenerator
  SLIP_HEIGHT = 26 
  SLIP_WIDTH  = 3  

  def initialize(payrolls, company_name)
    @payrolls = payrolls
    @company_display_name = company_name 
    
    # Sanitize name for file lookup: "U-BIX" -> "u_bix"
    safe_company_name = company_name.to_s.parameterize.underscore
    
    specific_path = Rails.root.join('lib', 'templates', "payslip_template_#{safe_company_name}.xlsx")
    @default_path = Rails.root.join('lib', 'templates', 'payslip_template.xlsx')

    @template_path = File.exist?(specific_path) ? specific_path : @default_path
  end

  def generate
    workbook = RubyXL::Parser.parse(@template_path)
    sheet = workbook[0]

    @payrolls.each_with_index do |payroll, index|
      page_index = index / 10
      pos_in_page = index % 10
      
      col_in_page = pos_in_page % 5
      col_offset = col_in_page * SLIP_WIDTH
      
      row_in_page = pos_in_page / 5
      row_offset = (row_in_page * SLIP_HEIGHT) + (page_index * 2 * SLIP_HEIGHT)

      # --- THE FIX ---
      # 1. Check the specific employee's company in the database.
      # 2. If it's blank, use the display name passed from the controller.
      # 3. If that's also "default", use a final fallback.
      employee_company = payroll.employee.company.presence || @company_display_name
      fallback   = ENV.fetch("DEFAULT_COMPANY_NAME", "")
      final_name = (employee_company.downcase == 'default') ? fallback : employee_company

      # Pass the specific name to the injector
      inject_values(sheet, row_offset, col_offset, payroll, true, final_name)
    end

    workbook
  end

  private

  # Added 'current_company_name' argument to receive the name from the loop
  def inject_values(sheet, r, c, p, show_header, current_company_name)
    update = ->(row_idx, col_idx, value, fallback = 0) {
      existing_cell = sheet[row_idx] && sheet[row_idx][col_idx]
      style_id = existing_cell ? existing_cell.style_index : nil
      
      new_cell = sheet.add_cell(row_idx, col_idx, value || fallback)
      new_cell.style_index = style_id if style_id
    }

    # --- BRANDING ---
    # Now uses the name we pulled from the employee record
    if show_header
      update.call(r + 0, c + 1, current_company_name.to_s.upcase, "")
    end

    # --- EMPLOYEE INFO ---
    update.call(r + 1, c + 1, p.employee.name, "")
    
    date_range = "#{p.start_date&.strftime('%m/%d')} - #{p.end_date&.strftime('%m/%d/%y')}"
    update.call(r + 2, c + 1, date_range, "")
    
    # --- EARNINGS ---
    update.call(r + 3, c + 1, p.daily_rate.to_f)
    update.call(r + 4, c + 1, p.days_worked.to_f)
    update.call(r + 5, c + 1, p.basic_pay.to_f)
    update.call(r + 6, c + 1, p.allowance.to_f)
    update.call(r + 7, c + 1, p.overtime_pay.to_f)
    update.call(r + 8, c + 1, p.rest_day_pay.to_f)
    update.call(r + 9, c + 1, p.holiday_pay.to_f)
    update.call(r + 10, c + 1, p.night_diff_pay.to_f)
    update.call(r + 11, c + 1, p.gross_pay.to_f)
    
    # --- OTHER DEDUCTIONS ---
    other_total = p.payroll_deductions.where.not(note: "Statutory").sum(:amount)
    update.call(r + 12, c,     "Other Deductions", "")
    update.call(r + 12, c + 1, other_total.to_f)

    # --- FIXED/STATUTORY DEDUCTIONS ---
    update.call(r + 13, c + 1, p.sss_amount.to_f)
    update.call(r + 14, c + 1, p.sss_loan.to_f)
    update.call(r + 15, c + 1, p.hdmf_amount.to_f)
    update.call(r + 16, c + 1, p.hdmf_loan.to_f)
    update.call(r + 17, c + 1, p.phic_amount.to_f)
    update.call(r + 18, c + 1, p.cash_advance.to_f)
    update.call(r + 18, c + 0, "CASH LOAN") # Label change for cash advance
    update.call(r + 19, c + 1, p.rice_deduction.to_f)
    update.call(r + 20, c + 1, p.materials_deduction.to_f)
    update.call(r + 21, c + 1, p.groceries_deduction.to_f)
    update.call(r + 22, c + 1, p.late_ut_amount.to_f)

    # --- TOTALS ---
    update.call(r + 23, c,     "TOTAL DEDUCTIONS", "")
    update.call(r + 23, c + 1, p.total_deductions.to_f)
    update.call(r + 24, c + 1, p.net_pay.to_f)
  end
end
class PayrollsController < ApplicationController
  before_action :set_payroll, only: %i[show edit update destroy]
  before_action :set_date_filters, only: %i[index bulk_print download_summary]

  def index
    @payrolls = fetch_filtered_payrolls
    @companies = Employee.distinct.pluck(:company).compact.sort
    
    respond_to do |format|
      format.html
      format.xlsx { send_summary_excel }
    end
  end

  def show
    @payroll = Payroll.includes(payroll_deductions: :deduction).find(params[:id])

    dtr_ids          = @payroll.daily_time_records.pluck(:id)
    slices           = TimeSlice.where(daily_time_record_id: dtr_ids)
    @slice_holiday_mins  = slices.where(holiday: true).sum(:minutes)
    @slice_rd_mins       = slices.where(rest_day: true, holiday: false).sum(:minutes)
    @slice_ot_mins       = slices.where(overtime: true, holiday: false, rest_day: false).sum(:minutes)
    @slice_reg_mins      = slices.where(overtime: false, holiday: false, rest_day: false, night_diff: false).sum(:minutes)
    @slice_nd_mins       = slices.where(night_diff: true).sum(:minutes)
    @total_clocked_mins  = @payroll.daily_time_records.sum { |d|
      d.clock_out && d.clock_in ? ((d.clock_out - d.clock_in) / 60).to_i : 0
    }

    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(template: 'payrolls/show', layout: 'pdf', formats: [:html])
        grover = Grover.new(html, format: 'A4', print_background: true)
        send_data grover.to_pdf, 
                  filename: "Payslip_#{@payroll.employee.name.parameterize}.pdf", 
                  type: 'application/pdf', 
                  disposition: 'inline'
      end
    end
  end

  def new
    @payroll = Payroll.new
  end

  def create
    @payroll = Payroll.new(payroll_params)
    if @payroll.save
      @payroll.calculate_final_amounts!
      redirect_to @payroll, notice: "Payroll created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def generate
    start_date = params[:start_date].presence&.to_date || Date.today.beginning_of_month
    end_date   = params[:end_date].presence&.to_date   || Date.today.end_of_month
    selected_companies = params[:companies]

    if selected_companies.blank?
      redirect_to payrolls_path, alert: "Please select at least one company to process." and return
    end

    employees_to_process = Employee.where(active: true, company: selected_companies)

    if params[:landbank_atm].present?
      employees_to_process = employees_to_process.where(landbank_atm: params[:landbank_atm] == "true")
    end

    if employees_to_process.empty?
      redirect_to payrolls_path, alert: "No employees match the selected criteria." and return
    end

    generator = PayrollGenerator.new(
      start_date:    start_date, 
      end_date:      end_date, 
      employees:     employees_to_process,
      deduction_ids: params[:deduction_ids] || [],
      custom_amounts: params[:custom_amounts],
      sss:           params[:apply_sss] == "1",
      ph:            params[:apply_ph]  == "1",
      pi:            params[:apply_pi]  == "1"
    )

    if generator.generate!
      redirect_to payrolls_path(start_date: start_date, end_date: end_date), 
                  notice: "Generated payroll for #{employees_to_process.count} employees."
    else
      redirect_to payrolls_path, alert: "Error during batch generation."
    end
  end

  def bulk_print
    @payrolls = fetch_filtered_payrolls

    if @payrolls.empty?
      redirect_to payrolls_path, alert: "No payroll records found for the selected filters." and return
    end

    respond_to do |format|
      format.pdf do
        html = render_to_string(template: 'payrolls/bulk_print', layout: 'pdf', formats: [:html])
        grover = Grover.new(html, 
          format: 'A4',
          margin: { top: '10mm', bottom: '10mm', left: '10mm', right: '10mm' },
          print_background: true
        )
        send_data grover.to_pdf, 
                  filename: "Bulk_Payslips_#{@start_date}.pdf", 
                  type: 'application/pdf', 
                  disposition: 'inline'
      end

      format.xlsx do
        selected_companies = Array(params[:companies])
        
        # 1. Determine which Template File to load.
        # If one company is selected, we try to load its specific .xlsx file.
        # Otherwise, we load the 'default' template file.
        template_key = selected_companies.size == 1 ? selected_companies.first : "default"

        # 2. Initialize the generator.
        # We pass template_key so it knows which FILE to open.
        # The generator will look at each individual payroll record to determine the PRINTED name.
        generator = ExcelPayrollGenerator.new(@payrolls, template_key)
        workbook = generator.generate
        
        send_data workbook.stream.read, 
                  filename: "Bulk_Payslips_#{@start_date}.xlsx", 
                  type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      end
    end
  end

  def download_summary
    @payrolls = fetch_filtered_payrolls
    send_summary_excel
  end

  def update
    if @payroll.update(payroll_params)
      @payroll.calculate_final_amounts!
      redirect_to @payroll, notice: "Payroll updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payroll.destroy!
    redirect_to payrolls_path, notice: "Payroll deleted.", status: :see_other
  end

  private

  def set_payroll
    @payroll = Payroll.includes(payroll_deductions: :deduction).find_by(id: params[:id])
    redirect_to payrolls_path, alert: "Payroll not found." if @payroll.nil?
  end

  def set_date_filters
    @start_date = params[:start_date].presence || Date.today.beginning_of_month.to_s
    @end_date   = params[:end_date].presence   || Date.today.end_of_month.to_s
  end

  def fetch_filtered_payrolls
    query = Payroll.includes(:employee, payroll_deductions: :deduction)
                   .where(start_date: @start_date..@end_date)

    if params[:companies].present?
      query = query.joins(:employee).where(employees: { company: params[:companies] })
    end

    if params[:landbank_atm].present?
      query = query.joins(:employee).where(employees: { landbank_atm: params[:landbank_atm] == "true" })
    end

    query.order("employees.name ASC")
  end

  def send_summary_excel
    display_name = Array(params[:companies]).size == 1 ? params[:companies].first : "Multiple Companies"
    period_label = "#{@start_date} to #{@end_date}"

    generator = ExcelSummaryGenerator.new(@payrolls, period_label, display_name)
    workbook = generator.generate

    send_data workbook.stream.read, 
              filename: "Payroll_Summary_#{@start_date}.xlsx", 
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def payroll_params
    params.require(:payroll).permit(
      :employee_id, :start_date, :end_date, :daily_rate, :days_worked,
      :allowance, :basic_pay, :overtime_pay, :rest_day_pay, :holiday_pay,
      :night_diff_pay, :gross_pay, :total_deductions, :net_pay, :status,
      :sss_amount, :phic_amount, :hdmf_amount, :sss_loan, :hdmf_loan,
      :cash_advance, :rice_deduction, :materials_deduction, :groceries_deduction, :late_ut_amount,
      :deduction_ids => [], 
      :payroll_deductions_attributes => [:id, :note, :amount, :_destroy]
    )
  end
end
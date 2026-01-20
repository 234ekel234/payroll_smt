class PayrollsController < ApplicationController
  before_action :set_payroll, only: %i[show edit update destroy]

  def index
    @payrolls = Payroll.includes(:employee, :payroll_deductions).order(start_date: :desc)
  end

  def show
  end

  def new
    @payroll = Payroll.new
  end

  def edit
  end

  def create
    @payroll = Payroll.new(payroll_params)

    if @payroll.save
      # Applies standard master deductions and statutory toggles via the model
      @payroll.apply_all_deductions(
        standard_ids: params[:payroll][:deduction_ids],
        sss: params[:apply_sss] == "1",
        ph:  params[:apply_ph]  == "1",
        pi:  params[:apply_pi]  == "1"
      )
      
      redirect_to @payroll, notice: "Payroll was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @payroll.update(payroll_params)
      # Re-apply logic: clears old snapshots and creates fresh ones based on new toggles
      @payroll.apply_all_deductions(
        standard_ids: params[:payroll][:deduction_ids],
        sss: params[:apply_sss] == "1",
        ph:  params[:apply_ph]  == "1",
        pi:  params[:apply_pi]  == "1"
      )

      redirect_to @payroll, notice: "Payroll was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payroll.destroy!
    redirect_to payrolls_path, notice: "Payroll was successfully destroyed.", status: :see_other
  end

  # POST /payrolls/generate
  # This handles the "Batch" generation using the PayrollGenerator Service
  def generate
    # 1. Capture dates from the dashboard form
    start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    end_date   = params[:end_date]&.to_date   || Date.today.end_of_month
    
    # 2. Capture Deduction Selections & Statutory Toggles
    selected_deduction_ids = params[:deduction_ids] || []
    
    # 3. Instantiate the Generator with all parameters
    generator = PayrollGenerator.new(
      start_date:    start_date, 
      end_date:      end_date, 
      employees:     Employee.where(active: true),
      deduction_ids: selected_deduction_ids,
      sss:           params[:apply_sss] == "1",
      ph:            params[:apply_ph]  == "1",
      pi:            params[:apply_pi]  == "1"
    )

    # 4. Execute the batch process
    if generator.generate!
      redirect_to payrolls_path, notice: "Batch payroll generated successfully for active employees."
    else
      redirect_to payrolls_path, alert: "There was an error generating batch payrolls."
    end
  end

  private

  def set_payroll
    @payroll = Payroll.find(params[:id])
  end

  def payroll_params
    # We permit the core attributes. deduction_ids are handled via params[:payroll][:deduction_ids]
    params.require(:payroll).permit(
      :employee_id, :start_date, :end_date, :daily_rate, :days_worked,
      :allowance, :basic_pay, :overtime_pay, :rest_day_pay, :holiday_pay,
      :night_diff_pay, :gross_pay, :total_deductions, :net_pay,
      :processed_at, :status
    )
  end
end
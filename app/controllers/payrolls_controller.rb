class PayrollsController < ApplicationController
  before_action :set_payroll, only: %i[show edit update destroy]

  def index
    # Order by date so the most recent payrolls appear at the top
    @payrolls = Payroll.includes(:employee, :payroll_deductions).order(start_date: :desc)
  end

  def show
  end

  def new
    @payroll = Payroll.new
    @payroll.payroll_deductions.build 
  end

  def edit
    @payroll.payroll_deductions.build if @payroll.payroll_deductions.empty?
  end

  def create
    @payroll = Payroll.new(payroll_params)

    if @payroll.save
      # Applies statutory deductions selected in the 'New' form
      @payroll.apply_deductions(params[:payroll][:deduction_ids])
      redirect_to @payroll, notice: "Payroll was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @payroll.update(payroll_params)
      # Re-calculates if statutory checkboxes were changed
      @payroll.apply_deductions(params[:payroll][:deduction_ids])
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
  def generate
    # 1. Capture dates from the batch form
    start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    end_date   = params[:end_date]&.to_date   || Date.today.end_of_month
    
    # 2. Capture the "On-the-fly" deductions selected in the batch card
    # We use 'params[:deduction_ids]' because it's outside the 'payroll' object in the index form
    selected_deduction_ids = params[:deduction_ids] || []

    employees = Employee.all # Or add a filter if you only want active employees

    # 3. Pass everything to the service object
    PayrollGenerator.new(
      start_date: start_date, 
      end_date: end_date, 
      employees: employees,
      deduction_ids: selected_deduction_ids # NEW: passing selection to generator
    ).generate!

    redirect_to payrolls_path, notice: "Payrolls generated successfully for #{employees.count} employees."
  end

  private

  def set_payroll
    @payroll = Payroll.find(params[:id])
  end

  def payroll_params
    params.require(:payroll).permit(
      :employee_id, :start_date, :end_date, :daily_rate, :days_worked,
      :allowance, :basic_pay, :overtime_pay, :rest_day_pay, :holiday_pay,
      :night_diff_pay, :gross_pay, :total_deductions, :net_pay,
      :processed_at, :status,
      deduction_ids: [],
      payroll_deductions_attributes: [:id, :amount, :note, :_destroy]
    )
  end
end
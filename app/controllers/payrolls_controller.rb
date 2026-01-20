class PayrollsController < ApplicationController
  # Uses find_by safety logic in set_payroll
  before_action :set_payroll, only: %i[show edit update destroy]

  def index
    # Added pagination-ready includes to prevent N+1 queries
    @payrolls = Payroll.includes(:employee, :payroll_deductions).order(start_date: :desc)
  end

  def show
    # @payroll is set by before_action
  end

  def new
    @payroll = Payroll.new
  end

  def edit
  end

  def create
    @payroll = Payroll.new(payroll_params)

    # Wrap in a transaction: If deductions fail, the payroll won't save at all
    ActiveRecord::Base.transaction do
      if @payroll.save
        apply_statutory_deductions(@payroll)
        redirect_to @payroll, notice: "Payroll was successfully created."
      else
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback # Prevents saving if validations fail
      end
    end
  end

  def update
    ActiveRecord::Base.transaction do
      if @payroll.update(payroll_params)
        apply_statutory_deductions(@payroll)
        redirect_to @payroll, notice: "Payroll was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    @payroll.destroy!
    redirect_to payrolls_path, notice: "Payroll was successfully destroyed.", status: :see_other
  end

  # POST /payrolls/generate
  def generate
    # 1. Capture dates & provide defaults
    start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    end_date   = params[:end_date]&.to_date   || Date.today.end_of_month
    
    # 2. Prevent duplicate payrolls for the same period
    existing = Payroll.where(start_date: start_date, end_date: end_date).exists?
    if existing && params[:force] != "true"
      return redirect_to payrolls_path, alert: "Payroll for this period already exists. Delete existing records first or use Force Generate."
    end

    # 3. Instantiate the Generator Service
    generator = PayrollGenerator.new(
      start_date:    start_date, 
      end_date:      end_date, 
      employees:     Employee.where(active: true),
      deduction_ids: params[:deduction_ids] || [],
      sss:           params[:apply_sss] == "1",
      ph:            params[:apply_ph]  == "1",
      pi:            params[:apply_pi]  == "1"
    )

    if generator.generate!
      redirect_to payrolls_path, notice: "Batch payroll generated successfully for active employees."
    else
      redirect_to payrolls_path, alert: "Error during batch generation. Check logs for details."
    end
  end

  private

  # SAFETY FIX: Prevents ActiveRecord::RecordNotFound (ID 255) crashes
  def set_payroll
    @payroll = Payroll.find_by(id: params[:id])
    
    if @payroll.nil?
      redirect_to payrolls_path, alert: "Error: Payroll record ##{params[:id]} could not be found. It may have been deleted."
    end
  end

  # Helper to dry up the deduction logic in Create/Update
  def apply_statutory_deductions(payroll)
    payroll.apply_all_deductions(
      standard_ids: params[:payroll][:deduction_ids],
      sss: params[:apply_sss] == "1",
      ph:  params[:apply_ph]  == "1",
      pi:  params[:apply_pi]  == "1"
    )
  end

  def payroll_params
    params.require(:payroll).permit(
      :employee_id, :start_date, :end_date, :daily_rate, :days_worked,
      :allowance, :basic_pay, :overtime_pay, :rest_day_pay, :holiday_pay,
      :night_diff_pay, :gross_pay, :total_deductions, :net_pay,
      :processed_at, :status
    )
  end
end
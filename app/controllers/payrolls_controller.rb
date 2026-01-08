class PayrollsController < ApplicationController
  before_action :set_payroll, only: %i[show edit update destroy]

  # GET /payrolls
  def index
    @payrolls = Payroll.all
  end

  # GET /payrolls/1
  def show
  end

  # GET /payrolls/new
  def new
    @payroll = Payroll.new
  end

  # GET /payrolls/1/edit
  def edit
  end

  # POST /payrolls
  def create
    @payroll = Payroll.new(payroll_params)

    respond_to do |format|
      if @payroll.save
        format.html { redirect_to @payroll, notice: "Payroll was successfully created." }
        format.json { render :show, status: :created, location: @payroll }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payroll.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payrolls/1
  def update
    respond_to do |format|
      if @payroll.update(payroll_params)
        format.html { redirect_to @payroll, notice: "Payroll was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @payroll }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payroll.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payrolls/1
  def destroy
    @payroll.destroy!
    respond_to do |format|
      format.html { redirect_to payrolls_path, notice: "Payroll was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /payrolls/generate
  def generate
    # You can optionally pass a period and/or employee filter
    start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    end_date   = params[:end_date]&.to_date   || Date.today.end_of_month
    employees  = params[:employee_ids] ? Employee.where(id: params[:employee_ids]) : Employee.all

    # Use a service object to handle the computation
    PayrollGenerator.new(start_date: start_date, end_date: end_date, employees: employees).generate!

    redirect_to payrolls_path, notice: "Payrolls generated successfully!"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payroll
    @payroll = Payroll.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def payroll_params
    params.require(:payroll).permit(
      :employee_id, :start_date, :end_date, :daily_rate, :days_worked,
      :allowance, :basic_pay, :overtime_pay, :rest_day_pay, :holiday_pay,
      :night_diff_pay, :gross_pay, :total_deductions, :net_pay,
      :processed_at, :status
    )
  end
end

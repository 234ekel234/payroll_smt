class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show edit update destroy]

  # GET /employees
  def index
    @employees = Employee.order(:name)
  end

  # GET /employees/1
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees
  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html do
          redirect_to @employee, notice: "Employee was successfully created."
        end
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employees/1
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html do
          redirect_to @employee,
            notice: "Employee was successfully updated.",
            status: :see_other
        end
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  def destroy
    @employee.destroy

    respond_to do |format|
      format.html do
        redirect_to employees_path,
          notice: "Employee was successfully deleted.",
          status: :see_other
      end
      format.json { head :no_content }
    end
  end

  private

  # Finds employee by ID
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Strong params (work_days ONLY, rest_days auto-derived)
  def employee_params
    params.require(:employee).permit(
      :name,
      :person_id,
      :company,
      :status_of_employment,
      :schedule,
      :basic_rate,
      :allowance_per_day,
      :landbank_atm,
      :shift_start,
      :shift_end,
      :break_start,
      :break_end,
      work_days: []   # ✅ VERY IMPORTANT
    )
  end
end

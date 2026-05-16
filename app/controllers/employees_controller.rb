class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show edit update destroy]

  # GET /employees
  def index
    # 1. Start with all employees and "Eager Load" shifts to prevent N+1 queries
    @employees = Employee.includes(:shift).all

    # 2. Filter by Name or ID (Case-insensitive search)
    if params[:query].present?
      @employees = @employees.where(
        "name ILIKE :search OR person_id ILIKE :search",
        search: "%#{params[:query]}%"
      )
    end

    # 3. Filter by Company
    if params[:company].present?
      @employees = @employees.where(company: params[:company])
    end

    # 4. Final Sorting
    @employees = @employees.order(:name)
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
        format.html { redirect_to @employee, notice: "Employee was successfully created." }
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
  def bulk_update
    @employees = Employee.where(id: params[:employee_ids])
    
    # Only build a hash of attributes that were actually selected
    updates = {}
    updates[:shift_id] = params[:shift_id] if params[:shift_id].present?
    updates[:company]  = params[:company]  if params[:company].present?

    if @employees.any? && updates.any?
      @employees.update_all(updates)
      redirect_to employees_path, notice: "Successfully updated #{@employees.count} employees."
    else
      redirect_to employees_path, alert: "No employees or changes selected."
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

  def set_employee
    @employee = Employee.find(params[:id])
  end

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
      :active,            # Added to support employment status toggles
      :shift_id,          # CRITICAL: Allows saving the Shift template selection
      :shift_start,       # Kept for individual overrides
      :shift_end,
      :break_start,
      :break_end,
      work_days: []
    )
  end
end
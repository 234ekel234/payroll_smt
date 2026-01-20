class DeductionsController < ApplicationController
  before_action :set_deduction, only: %i[ show edit update destroy toggle_status ]

  # GET /deductions
  def index
    # We order by active status so current ones stay at the top
    @deductions = Deduction.order(active: :desc, name: :asc)
  end

  # GET /deductions/1
  def show
  end

  # GET /deductions/new
  def new
    @deduction = Deduction.new(active: true) # Default to active for new records
  end

  # GET /deductions/1/edit
  def edit
  end

  # POST /deductions
  def create
    @deduction = Deduction.new(deduction_params)

    if @deduction.save
      redirect_to deductions_path, notice: "Deduction '#{@deduction.name}' was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /deductions/1
  def update
    if @deduction.update(deduction_params)
      redirect_to deductions_path, notice: "Deduction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /deductions/1
  # This replaces hard-delete with deactivation to protect foreign key integrity
  def destroy
    if @deduction.update(active: false)
      redirect_to deductions_path, notice: "Deduction was archived. It won't affect new payrolls but remains in history."
    else
      redirect_to deductions_path, alert: "Could not deactivate deduction."
    end
  end

  # PATCH /deductions/1/toggle_status
  # Custom action to allow easy Re-activation from the index view
  def toggle_status
    new_status = !@deduction.active
    @deduction.update(active: new_status)
    
    message = new_status ? "Deduction is now Active." : "Deduction has been Archived."
    redirect_to deductions_path, notice: message
  end

  private

  def set_deduction
    # Rails 8 'expect' style but safe for standard IDs
    @deduction = Deduction.find(params[:id])
  end

  def deduction_params
    params.require(:deduction).permit(
      :name, 
      :amount, 
      :amount_type, 
      :category, 
      :deduction_type, 
      :active, 
      :notes, 
      :applies_to, 
      :employee_group_id
    )
  end
end
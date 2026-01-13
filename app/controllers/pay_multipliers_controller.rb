class PayMultipliersController < ApplicationController
  before_action :set_pay_multiplier, only: %i[ show edit update destroy ]

  # GET /pay_multipliers or /pay_multipliers.json
  def index
    @pay_multipliers = PayMultiplier.all
  end

  # GET /pay_multipliers/1 or /pay_multipliers/1.json
  def show
  end

  # GET /pay_multipliers/new
  def new
    @pay_multiplier = PayMultiplier.new
  end

  # GET /pay_multipliers/1/edit
  def edit
  end

  # POST /pay_multipliers or /pay_multipliers.json
  def create
    @pay_multiplier = PayMultiplier.new(pay_multiplier_params)

    respond_to do |format|
      if @pay_multiplier.save
        format.html { redirect_to @pay_multiplier, notice: "Pay multiplier was successfully created." }
        format.json { render :show, status: :created, location: @pay_multiplier }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pay_multiplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pay_multipliers/1 or /pay_multipliers/1.json
  def update
    respond_to do |format|
      if @pay_multiplier.update(pay_multiplier_params)
        format.html { redirect_to @pay_multiplier, notice: "Pay multiplier was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @pay_multiplier }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pay_multiplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pay_multipliers/1 or /pay_multipliers/1.json
  def destroy
    @pay_multiplier.destroy!

    respond_to do |format|
      format.html { redirect_to pay_multipliers_path, notice: "Pay multiplier was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pay_multiplier
      @pay_multiplier = PayMultiplier.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pay_multiplier_params
      params.expect(pay_multiplier: [ :code, :name, :holiday_type, :rest_day, :overtime, :base_multiplier ])
    end
end

class GovDeductionBracketsController < ApplicationController
  before_action :set_gov_deduction_bracket, only: %i[ show edit update destroy ]

  # GET /gov_deduction_brackets or /gov_deduction_brackets.json
  def index
    @gov_deduction_brackets = GovDeductionBracket.all

    # Simple filter logic
    if params[:query].present?
      # This filters by the enum name (SSS, PHIC, HDMF)
      @gov_deduction_brackets = @gov_deduction_brackets.where(deduction_type: params[:query].downcase)
    end
  end

  # GET /gov_deduction_brackets/1 or /gov_deduction_brackets/1.json
  def show
  end

  # GET /gov_deduction_brackets/new
  def new
    @gov_deduction_bracket = GovDeductionBracket.new
  end

  # GET /gov_deduction_brackets/1/edit
  def edit
  end

  # POST /gov_deduction_brackets or /gov_deduction_brackets.json
  def create
    @gov_deduction_bracket = GovDeductionBracket.new(gov_deduction_bracket_params)

    respond_to do |format|
      if @gov_deduction_bracket.save
        format.html { redirect_to @gov_deduction_bracket, notice: "Gov deduction bracket was successfully created." }
        format.json { render :show, status: :created, location: @gov_deduction_bracket }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gov_deduction_bracket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gov_deduction_brackets/1 or /gov_deduction_brackets/1.json
  def update
    respond_to do |format|
      if @gov_deduction_bracket.update(gov_deduction_bracket_params)
        format.html { redirect_to @gov_deduction_bracket, notice: "Gov deduction bracket was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @gov_deduction_bracket }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gov_deduction_bracket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gov_deduction_brackets/1 or /gov_deduction_brackets/1.json
  def destroy
    @gov_deduction_bracket.destroy!

    respond_to do |format|
      format.html { redirect_to gov_deduction_brackets_path, notice: "Gov deduction bracket was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gov_deduction_bracket
      @gov_deduction_bracket = GovDeductionBracket.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def gov_deduction_bracket_params
      params.expect(gov_deduction_bracket: [ :amount, :deduction_type, :range_max, :range_min ])
    end
end

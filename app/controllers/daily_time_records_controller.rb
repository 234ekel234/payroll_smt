class DailyTimeRecordsController < ApplicationController
  before_action :set_daily_time_record, only: %i[ show edit update destroy ]

  # GET /daily_time_records or /daily_time_records.json
  def index
    @daily_time_records = DailyTimeRecord.all
  end

  # GET /daily_time_records/1 or /daily_time_records/1.json
  def show
  end

  # GET /daily_time_records/new
  def new
    @daily_time_record = DailyTimeRecord.new
  end

  # GET /daily_time_records/1/edit
  def edit
  end

  # POST /daily_time_records or /daily_time_records.json
  def create
    @daily_time_record = DailyTimeRecord.new(daily_time_record_params)

    respond_to do |format|
      if @daily_time_record.save
        format.html { redirect_to @daily_time_record, notice: "Daily time record was successfully created." }
        format.json { render :show, status: :created, location: @daily_time_record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @daily_time_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_time_records/1 or /daily_time_records/1.json
  def update
    respond_to do |format|
      if @daily_time_record.update(daily_time_record_params)
        format.html { redirect_to @daily_time_record, notice: "Daily time record was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @daily_time_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @daily_time_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_time_records/1 or /daily_time_records/1.json
  def destroy
    @daily_time_record.destroy!

    respond_to do |format|
      format.html { redirect_to daily_time_records_path, notice: "Daily time record was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_time_record
      @daily_time_record = DailyTimeRecord.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def daily_time_record_params
      params.expect(daily_time_record: [ :employee_id, :date, :clock_in, :clock_out, :night_diff_minutes, :overtime_minutes, :abnormal_situation ])
    end
end

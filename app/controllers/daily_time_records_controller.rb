# app/controllers/daily_time_records_controller.rb
class DailyTimeRecordsController < ApplicationController
  before_action :set_daily_time_record, only: %i[show edit update destroy]

  # GET /daily_time_records
  def index
    @daily_time_records = DailyTimeRecord.includes(:employee).order(date: :desc)
  end

  # GET /daily_time_records/:id
  def show
  end

  # GET /daily_time_records/new
  def new
    @daily_time_record = DailyTimeRecord.new
  end

  # GET /daily_time_records/:id/edit
  def edit
  end

  # POST /daily_time_records
  def create
    @daily_time_record = DailyTimeRecord.new(daily_time_record_params)
    if @daily_time_record.save
      redirect_to @daily_time_record, notice: "Daily Time Record was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /daily_time_records/:id
  def update
    if @daily_time_record.update(daily_time_record_params)
      redirect_to @daily_time_record, notice: "Daily Time Record was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /daily_time_records/:id
  def destroy
    @daily_time_record.destroy
    redirect_to daily_time_records_path, notice: "Daily Time Record was successfully destroyed."
  end

  # POST /daily_time_records/import_file
  def import_file
    if params[:file].present?
      DailyTimeRecordImporter.new(file: params[:file]).import
      redirect_to daily_time_records_path, notice: "DTRs imported successfully from file!"
    else
      redirect_to daily_time_records_path, alert: "Please attach a file to import."
    end
  end

  # POST /daily_time_records/import_google
  def import_google
    if params[:spreadsheet_id].present?
      DailyTimeRecordImporter.new(google_sheet_id: params[:spreadsheet_id]).import
      redirect_to daily_time_records_path, notice: "DTRs imported successfully from Google Sheets!"
    else
      redirect_to daily_time_records_path, alert: "Please provide a Google Sheet ID."
    end
  end

  private

  def set_daily_time_record
    @daily_time_record = DailyTimeRecord.find(params[:id])
  end

  def daily_time_record_params
    params.require(:daily_time_record).permit(:employee_id, :date, :clock_in, :clock_out, :abnormal_situation)
  end
end

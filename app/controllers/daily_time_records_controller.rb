class DailyTimeRecordsController < ApplicationController
  before_action :set_daily_time_record, only: %i[show edit update destroy]

  def index
    # 1. Base query with eager loading to prevent N+1 queries
    @daily_time_records = DailyTimeRecord.includes(:employee).order(date: :desc)

    # 2. Filter by Employee Name
    if params[:employee_name].present?
      @daily_time_records = @daily_time_records.joins(:employee)
                                             .where("employees.name ILIKE ?", "%#{params[:employee_name]}%")
    end

    # 3. Filter by Company
    if params[:company].present?
      @daily_time_records = @daily_time_records.joins(:employee)
                                             .where(employees: { company: params[:company] })
    end

    # 4. Filter by Status (Simplified to Absence and Lates only)
    case params[:status]
    when "Abnormal"
      # Show lates/issues but NOT total absences
      @daily_time_records = @daily_time_records.where.not(abnormal_situation: [nil, "", "Absence"])
    when "Absence"
      # Show only total absences
      @daily_time_records = @daily_time_records.where(abnormal_situation: "Absence")
    when "Normal"
      # Show only clean records
      @daily_time_records = @daily_time_records.where(abnormal_situation: [nil, ""])
    end

    # 5. Filter by Date Range
    if params[:start_date].present? && params[:end_date].present?
      @daily_time_records = @daily_time_records.where(date: params[:start_date]..params[:end_date])
    end

    # 6. PAGINATION: Wrap the filtered results
    # We show 20 records per page to keep loading times instant
    @pagy, @daily_time_records = pagy(@daily_time_records, items: 20)
  end

  def show
  end

  def new
    @daily_time_record = DailyTimeRecord.new
  end

  def edit
  end

  def create
    @daily_time_record = DailyTimeRecord.new(daily_time_record_params)
    if @daily_time_record.save
      redirect_to @daily_time_record, notice: "Daily Time Record was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @daily_time_record.update(daily_time_record_params)
      redirect_to @daily_time_record, notice: "Daily Time Record was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @daily_time_record.destroy
    redirect_to daily_time_records_path, notice: "Daily Time Record was successfully destroyed."
  end

  def import_file
    if params[:file].present?
      begin
        importer = DailyTimeRecordImporter.new(file: params[:file])
        importer.import
        redirect_to daily_time_records_path, notice: "DTRs imported successfully!"
      rescue => e
        redirect_to daily_time_records_path, alert: "Import failed: #{e.message}"
      end
    else
      redirect_to daily_time_records_path, alert: "Please attach a file."
    end
  end

  def import_google
    if params[:spreadsheet_id].present?
      begin
        importer = DailyTimeRecordImporter.new(google_sheet_id: params[:spreadsheet_id])
        importer.import
        redirect_to daily_time_records_path, notice: "Google Sheets sync successful!"
      rescue => e
        redirect_to daily_time_records_path, alert: "Sync failed: #{e.message}"
      end
    else
      redirect_to daily_time_records_path, alert: "Please provide a Google Sheet ID."
    end
  end

  private

  def set_daily_time_record
    @daily_time_record = DailyTimeRecord.find(params[:id])
  end

  def daily_time_record_params
    params.require(:daily_time_record).permit(
      :employee_id, :date, :clock_in, :clock_out, 
      :abnormal_situation, :late_minutes, :overtime_minutes, 
      :night_diff_minutes, :holiday_minutes, :total_work_minutes
    )
  end
end
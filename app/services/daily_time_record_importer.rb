# app/services/daily_time_record_importer.rb
class DailyTimeRecordImporter
  require 'roo'
  require 'google/apis/sheets_v4'
  require 'googleauth'

  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  def initialize(file: nil, google_sheet_id: nil, sheet_range: "Sheet1!A2:F")
    @file = file
    @google_sheet_id = google_sheet_id&.include?("docs.google.com") ? extract_spreadsheet_id(google_sheet_id) : google_sheet_id
    @sheet_range = sheet_range
  end

  # ------------------------
  # Entry Point
  # ------------------------
  def import
    if @google_sheet_id
      import_from_google
    elsif @file
      import_from_file
    else
      raise ArgumentError, "No source provided for import"
    end
  end

  private

  # ------------------------
  # Google Sheets import
  # ------------------------
  def import_from_google
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(Rails.root.join("config/google_service_account.json")),
      scope: SCOPE
    )

    response = service.get_spreadsheet_values(@google_sheet_id, @sheet_range)
    response.values.each_with_index do |row, index|
      import_row(row, index + 2) # +2 because of header
    end
  end

  # ------------------------
  # Local file import (CSV/XLSX)
  # ------------------------
  def import_from_file
    spreadsheet = Roo::Spreadsheet.open(@file.path)
    sheet = spreadsheet.sheet(0)

    sheet.each_row_streaming(offset: 1) do |row|
      values = row.map(&:cell_value)
      import_row(values)
    end
  end

  # ------------------------
  # Process single row
  # ------------------------
  def import_row(row, row_number = nil)
    person_id, fname, lname, date_val, clock_in_val, clock_out_val = row

    employee = Employee.find_by(person_id: person_id)
    unless employee
      log_warn("Row #{row_number}: Employee #{person_id} not found, skipping") if row_number
      return
    end

    date = parse_date(date_val)
    unless date
      log_warn("Row #{row_number}: Invalid date '#{date_val}', skipping") if row_number
      return
    end

    clock_in  = parse_time_for_date(clock_in_val, date)
    clock_out = parse_time_for_date(clock_out_val, date)
    unless clock_in && clock_out
      log_warn("Row #{row_number}: Invalid clock in/out time, skipping") if row_number
      return
    end

    # FIX: Handle overnight shifts (e.g., 10 PM to 6 AM)
    clock_out += 1.day if clock_out <= clock_in

    record = DailyTimeRecord.find_or_initialize_by(employee: employee, date: date)
    record.clock_in  = clock_in
    record.clock_out = clock_out

    if record.save
      log_info("Row #{row_number || ''}: Imported #{person_id} on #{date}")
    else
      log_warn("Row #{row_number || ''}: Failed to save record: #{record.errors.full_messages.join(', ')}")
    end
  end

  # ------------------------
  # Helpers
  # ------------------------
  def parse_time_for_date(value, date)
    return nil if value.blank?
    
    # FIX: Use Time.zone to respect Asia/Manila and prevent timezone shifting
    begin
      t = value.is_a?(Time) || value.is_a?(DateTime) ? value : Time.zone.parse(value.to_s)
      return nil unless t

      # Re-build local time using the App's timezone
      Time.zone.local(date.year, date.month, date.day, t.hour, t.min, t.sec)
    rescue ArgumentError
      nil
    end
  end

  def parse_date(value)
    return nil if value.blank?
    return value if value.is_a?(Date) || value.is_a?(DateTime)
    Date.parse(value.to_s) rescue nil
  end

  def extract_spreadsheet_id(url)
    match = url.match(%r{/d/([a-zA-Z0-9-_]+)})
    raise ArgumentError, "Invalid Google Sheet URL" unless match
    match[1]
  end

  def log_warn(message)
    Rails.logger.warn(message)
    puts message
  end

  def log_info(message)
    Rails.logger.info(message)
    puts message
  end
end
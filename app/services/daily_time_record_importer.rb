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

  # Entry point
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
      person_id, fname, lname, date_str, clock_in_str, clock_out_str = row

      employee = Employee.find_by(person_id: person_id)
      unless employee
        Rails.logger.warn "Row #{index + 2}: Employee #{person_id} not found, skipping"
        next
      end

      date = parse_date(date_str)
      unless date
        Rails.logger.warn "Row #{index + 2}: Invalid date '#{date_str}', skipping"
        next
      end

      clock_in = parse_time_for_date(clock_in_str, date)
      clock_out = parse_time_for_date(clock_out_str, date)

      unless clock_in && clock_out
        Rails.logger.warn "Row #{index + 2}: Invalid clock in/out time, skipping"
        next
      end

      record = DailyTimeRecord.find_or_initialize_by(employee: employee, date: date)
      record.clock_in  = clock_in
      record.clock_out = clock_out

      if record.save
        Rails.logger.info "Row #{index + 2}: Imported #{person_id} on #{date}"
      else
        Rails.logger.warn "Row #{index + 2}: Failed to save record: #{record.errors.full_messages.join(', ')}"
      end
    end
  end

  # ------------------------
  # Local file import (CSV/XLSX)
  # ------------------------
  def import_from_file
    spreadsheet = Roo::Spreadsheet.open(@file.path)
    sheet = spreadsheet.sheet(0)

    sheet.each_row_streaming(offset: 1) do |row|
      person_id, fname, lname, date_val, clock_in_val, clock_out_val = row.map { |c| c.cell_value }

      employee = Employee.find_by(person_id: person_id)
      next unless employee

      date = parse_date(date_val)
      next unless date

      clock_in = parse_time_for_date(clock_in_val, date)
      clock_out = parse_time_for_date(clock_out_val, date)
      next unless clock_in && clock_out

      record = DailyTimeRecord.find_or_initialize_by(employee: employee, date: date)
      record.clock_in  = clock_in
      record.clock_out = clock_out

      if record.save
        Rails.logger.info "Imported #{person_id} on #{date}"
      else
        Rails.logger.warn "Failed to save record for #{person_id} on #{date}: #{record.errors.full_messages.join(', ')}"
      end
    end
  end

  # ------------------------
  # Helpers
  # ------------------------
  # Parse string like "9:00:00" and combine with date
  def parse_time_for_date(value, date)
    return nil if value.blank?
    return value if value.is_a?(Time) || value.is_a?(DateTime)

    begin
      t = Time.parse(value.to_s)
      DateTime.new(date.year, date.month, date.day, t.hour, t.min, t.sec)
    rescue ArgumentError
      nil
    end
  end

  # Parse date strings
  def parse_date(value)
    return nil if value.blank?
    return value if value.is_a?(Date) || value.is_a?(DateTime)

    Date.parse(value.to_s) rescue nil
  end

  # Extract Google Sheet ID from full URL
  def extract_spreadsheet_id(url)
    match = url.match(%r{/d/([a-zA-Z0-9-_]+)})
    raise ArgumentError, "Invalid Google Sheet URL" unless match
    match[1]
  end
end

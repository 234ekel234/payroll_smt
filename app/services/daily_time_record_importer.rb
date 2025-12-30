# app/services/daily_time_record_importer.rb
class DailyTimeRecordImporter
  require 'roo'
  require 'google/apis/sheets_v4'
  require 'googleauth'

  SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

  def initialize(file: nil, google_sheet_id: nil, sheet_range: "Sheet1!A2:D")
    @file = file
    @google_sheet_id = google_sheet_id
    @sheet_range = sheet_range
  end

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

  def import_from_google
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(Rails.root.join("config", "google_service_account.json")),
      scope: SCOPE
    )

    response = service.get_spreadsheet_values(@google_sheet_id, @sheet_range)

    response.values.each do |row|
      employee = Employee.find_by(person_id: row[0])
      next unless employee

      employee.daily_time_records.create(
        date: Date.parse(row[1]),
        clock_in: Time.parse(row[2]),
        clock_out: Time.parse(row[3])
      )
    end
  end

  def import_from_file
    spreadsheet = Roo::Spreadsheet.open(@file.path)
    sheet = spreadsheet.sheet(0)

    sheet.each_row_streaming(offset: 1) do |row|
      employee = Employee.find_by(person_id: row[0].cell_value)
      next unless employee

      employee.daily_time_records.create(
        date: row[1].cell_value,
        clock_in: row[2].cell_value,
        clock_out: row[3].cell_value
      )
    end
  end
end

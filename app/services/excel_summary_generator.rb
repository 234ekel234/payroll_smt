# frozen_string_literal: true

# Generates a filled FINAL PAYROLL SUMMARY .xlsx from a collection of Payroll records.
#
# All values are written directly from computed app data — Excel formulas in the
# template are intentionally ignored. This means every cell contains a real value,
# dashes are written for zero amounts, and there are no #VALUE! risks.
#
# Usage:
#   wb = ExcelSummaryGenerator.new(payrolls, "May 1–15, 2026", "FMI Corporation").generate
#   send_data wb.stream.string,
#     filename: "payroll_summary_#{Date.today}.xlsx",
#     type:     "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

class ExcelSummaryGenerator
  DATA_START_ROW = 10

  # ---------------------------------------------------------------------------
  # Column index map (1-based)
  # We write directly to every meaningful column — HR/MIN inputs for time context,
  # and PAY columns with computed amounts from the app. Formulas are ignored.
  # ---------------------------------------------------------------------------
  COL = {
    # Identity
    name:              2,   # B
    status:            3,   # C
    days_worked:       4,   # D
    daily_rate:        5,   # E
    allowance_per_day: 6,   # F  per day
    allowance_total:   7,   # G  total allowance

    # Overtime Pay
    ot_hr:             8,   # H
    ot_min:            9,   # I
    ot_total_time:     10,  # J
    ot_pay:            11,  # K

    # Rest Day Pay
    rd_hr:             12,  # L
    rd_pay:            13,  # M

    # OT Rest Day Pay
    ot_rd_hr:          14,  # N
    ot_rd_min:         15,  # O
    ot_rd_total_time:  16,  # P
    ot_rd_pay:         17,  # Q

    # Special Non-Working Holiday Pay
    snwh_hr:           18,  # R
    snwh_pay:          19,  # S
    ot_snwh_hr:        20,  # T
    ot_snwh_min:       21,  # U
    ot_snwh_total:     22,  # V
    ot_snwh_pay:       23,  # W

    # SNWH on Rest Day
    snwh_rd_hr:        24,  # X
    snwh_rd_pay:       25,  # Y
    ot_snwh_rd_hr:     26,  # Z
    ot_snwh_rd_min:    27,  # AA
    ot_snwh_rd_total:  28,  # AB
    ot_snwh_rd_pay:    29,  # AC

    # Regular Holiday (Not Worked)
    rh_not_worked_hr:  30,  # AD
    rh_not_worked_pay: 31,  # AE

    # Regular Holiday (Worked)
    rh_hr:             32,  # AF
    rh_pay:            33,  # AG

    # OT Regular Holiday
    ot_rh_hr:          34,  # AH
    ot_rh_min:         35,  # AI
    ot_rh_total:       36,  # AJ
    ot_rh_pay:         37,  # AK

    # Regular Holiday on Rest Day
    rh_rd_hr:          38,  # AL
    rh_rd_pay:         39,  # AM
    ot_rh_rd_hr:       40,  # AN
    ot_rh_rd_min:      41,  # AO
    ot_rh_rd_total:    42,  # AP
    ot_rh_rd_pay:      43,  # AQ

    # ND – Ordinary Working Day
    nd_ord_hr:         44,  # AR
    nd_ord_min:        45,  # AS
    nd_ord_total:      46,  # AT
    nd_ord_pay:        47,  # AU

    # ND – OT Ordinary Working Day
    nd_ot_hr:          48,  # AV
    nd_ot_min:         49,  # AW
    nd_ot_total:       50,  # AX
    nd_ot_pay:         51,  # AY

    # ND – Rest Day
    nd_rd_hr:          52,  # AZ
    nd_rd_min:         53,  # BA
    nd_rd_total:       54,  # BB
    nd_rd_pay:         55,  # BC

    # ND – OT Rest Day
    nd_ot_rd_hr:       56,  # BD
    nd_ot_rd_min:      57,  # BE
    nd_ot_rd_total:    58,  # BF
    nd_ot_rd_pay:      59,  # BG

    # ND – SNWH
    nd_snwh_hr:        60,  # BH
    nd_snwh_min:       61,  # BI
    nd_snwh_total:     62,  # BJ
    nd_snwh_pay:       63,  # BK

    # ND – OT SNWH
    nd_ot_snwh_hr:     64,  # BL
    nd_ot_snwh_min:    65,  # BM
    nd_ot_snwh_total:  66,  # BN
    nd_ot_snwh_pay:    67,  # BO

    # ND – SNWH Rest Day
    nd_snwh_rd_hr:     68,  # BP
    nd_snwh_rd_min:    69,  # BQ
    nd_snwh_rd_total:  70,  # BR
    nd_snwh_rd_pay:    71,  # BS

    # ND – OT SNWH Rest Day
    nd_ot_snwh_rd_hr:   72,  # BT
    nd_ot_snwh_rd_min:  73,  # BU
    nd_ot_snwh_rd_total: 74, # BV
    nd_ot_snwh_rd_pay:  75,  # BW

    # ND – Regular Holiday
    nd_rh_hr:          76,  # BX
    nd_rh_min:         77,  # BY
    nd_rh_total:       78,  # BZ
    nd_rh_pay:         79,  # CA

    # ND – OT Regular Holiday
    nd_ot_rh_hr:       80,  # CB
    nd_ot_rh_min:      81,  # CC
    nd_ot_rh_total:    82,  # CD
    nd_ot_rh_pay:      83,  # CE

    # ND – Regular Holiday Rest Day
    nd_rh_rd_hr:       84,  # CF
    nd_rh_rd_min:      85,  # CG
    nd_rh_rd_total:    86,  # CH
    nd_rh_rd_pay:      87,  # CI

    # ND – OT Regular Holiday Rest Day
    nd_ot_rh_rd_hr:    88,  # CJ
    nd_ot_rh_rd_min:   89,  # CK
    nd_ot_rh_rd_total: 90,  # CL
    nd_ot_rh_rd_pay:   91,  # CM

    # Reimbursements
    reimbursements:    92,  # CN

    # Gross / Deductions / Net
    gross_pay:         93,  # CO
    sss_amount:        94,  # CP
    sss_loan:          95,  # CQ
    hdmf_amount:       96,  # CR
    hdmf_loan:         97,  # CS
    phic_amount:       98,  # CT
    cash_advance:      99,  # CU
    rice_deduction:    100, # CV
    materials_deduction: 101, # CW
    groceries_deduction: 102, # CX
    late_ut_amount:    103, # CY
    total_deductions:  105, # DA
    net_pay:           106, # DB
  }.freeze

  def initialize(payrolls, period_label, company_name,
                 prepared_by: "Elaine Beatriz C. Bello",
                 prepared_by_title: "HR",
                 approved_by: "Ms. Winalene E. Sescar",
                 approved_by_title: "")
    @payrolls          = payrolls
    @period_label      = period_label
    @company_name      = company_name.presence || "ALL COMPANIES"
    @prepared_by       = prepared_by
    @prepared_by_title = prepared_by_title
    @approved_by       = approved_by
    @approved_by_title = approved_by_title
    @template_path     = Rails.root.join("lib", "templates", "payroll_summary_template.xlsx")
  end

  def generate
    workbook = RubyXL::Parser.parse(@template_path.to_s)
    workbook.calc_pr.full_calc_on_load = false  # not using formulas

    sheet = workbook[0]  # FINAL PAYROLL SUMMARY

    write_header(sheet)
    write_employees(sheet)
    hide_inactive_columns(sheet)

    workbook
  end

  private

  def write_header(sheet)
    sheet.add_cell(1, 3, @company_name.upcase)
    sheet.add_cell(2, 3, "Salaries & Wages")
    sheet.add_cell(3, 3, "Period: #{@period_label}")
  end

  # Columns always shown regardless of values
  ALWAYS_SHOW = %i[
    name status days_worked daily_rate allowance_per_day allowance_total
    gross_pay sss_amount sss_loan hdmf_amount hdmf_loan phic_amount
    cash_advance rice_deduction materials_deduction groceries_deduction
    late_ut_amount total_deductions net_pay
  ].freeze

  def write_employees(sheet)
    # Clear template's hardcoded footer rows (17–21, 0-based 16–20)
    (16..20).each do |r|
      sheet.sheet_data[r]&.cells&.each { |c| c&.change_contents(nil) rescue nil }
    end

    # Cache row 10's styles and height before writing anything
    template_row_0 = DATA_START_ROW - 1
    @row10_styles  = {}
    sheet.sheet_data[template_row_0]&.cells&.each do |cell|
      next unless cell
      @row10_styles[cell.column] = cell.style_index
    end
    @row10_height = sheet.sheet_data[template_row_0].ht || 51

    # --- Step 1: Buffer all employee data first ---
    buffer = @payrolls.map do |payroll|
      slices = fetch_slices(payroll)
      times  = compute_times(slices)
      pays   = compute_pays(slices)

      {
        # Identity (always shown)
        name:              payroll.employee.name,
        status:            payroll.employee.status_of_employment.to_s,
        days_worked:       payroll.days_worked.to_i,
        daily_rate:        payroll.daily_rate.to_f,
        allowance_per_day: payroll.employee.allowance_per_day.to_f,
        allowance_total:   payroll.allowance.to_f,

        # OT
        ot_hr:             times[:ot_hr],
        ot_min:            times[:ot_min],
        ot_total_time:     times[:ot_total],
        ot_pay:            pays[:ot],

        # Rest Day
        rd_hr:             times[:rd_hr],
        rd_pay:            pays[:rd],

        # OT Rest Day
        ot_rd_hr:          times[:ot_rd_hr],
        ot_rd_min:         times[:ot_rd_min],
        ot_rd_total_time:  times[:ot_rd_total],
        ot_rd_pay:         pays[:ot_rd],

        # SNWH
        snwh_hr:           times[:snwh_hr],
        snwh_pay:          pays[:snwh],
        ot_snwh_hr:        times[:ot_snwh_hr],
        ot_snwh_min:       times[:ot_snwh_min],
        ot_snwh_total:     times[:ot_snwh_total],
        ot_snwh_pay:       pays[:ot_snwh],

        # SNWH Rest Day
        snwh_rd_hr:        times[:snwh_rd_hr],
        snwh_rd_pay:       pays[:snwh_rd],
        ot_snwh_rd_hr:     times[:ot_snwh_rd_hr],
        ot_snwh_rd_min:    times[:ot_snwh_rd_min],
        ot_snwh_rd_total:  times[:ot_snwh_rd_total],
        ot_snwh_rd_pay:    pays[:ot_snwh_rd],

        # Regular Holiday
        rh_not_worked_hr:  payroll.daily_rate.to_f > 0 ? ((payroll.absent_holiday_pay.to_f / payroll.daily_rate.to_f) * shift_hours(payroll.employee)).round : 0,
        rh_not_worked_pay: payroll.absent_holiday_pay.to_f,
        rh_hr:             times[:rh_hr],
        rh_pay:            pays[:rh],
        ot_rh_hr:          times[:ot_rh_hr],
        ot_rh_min:         times[:ot_rh_min],
        ot_rh_total:       times[:ot_rh_total],
        ot_rh_pay:         pays[:ot_rh],
        rh_rd_hr:          times[:rh_rd_hr],
        rh_rd_pay:         pays[:rh_rd],
        ot_rh_rd_hr:       times[:ot_rh_rd_hr],
        ot_rh_rd_min:      times[:ot_rh_rd_min],
        ot_rh_rd_total:    times[:ot_rh_rd_total],
        ot_rh_rd_pay:      pays[:ot_rh_rd],

        # ND Ordinary
        nd_ord_hr:         times[:nd_ord_hr],
        nd_ord_min:        times[:nd_ord_min],
        nd_ord_total:      times[:nd_ord_total],
        nd_ord_pay:        pays[:nd_ord],

        # ND OT
        nd_ot_hr:          times[:nd_ot_hr],
        nd_ot_min:         times[:nd_ot_min],
        nd_ot_total:       times[:nd_ot_total],
        nd_ot_pay:         pays[:nd_ot],

        # ND Rest Day
        nd_rd_hr:          times[:nd_rd_hr],
        nd_rd_min:         times[:nd_rd_min],
        nd_rd_total:       times[:nd_rd_total],
        nd_rd_pay:         pays[:nd_rd],

        # ND OT Rest Day
        nd_ot_rd_hr:       times[:nd_ot_rd_hr],
        nd_ot_rd_min:      times[:nd_ot_rd_min],
        nd_ot_rd_total:    times[:nd_ot_rd_total],
        nd_ot_rd_pay:      pays[:nd_ot_rd],

        # ND SNWH
        nd_snwh_hr:        times[:nd_snwh_hr],
        nd_snwh_min:       times[:nd_snwh_min],
        nd_snwh_total:     times[:nd_snwh_total],
        nd_snwh_pay:       pays[:nd_snwh],

        # ND OT SNWH
        nd_ot_snwh_hr:     times[:nd_ot_snwh_hr],
        nd_ot_snwh_min:    times[:nd_ot_snwh_min],
        nd_ot_snwh_total:  times[:nd_ot_snwh_total],
        nd_ot_snwh_pay:    pays[:nd_ot_snwh],

        # ND SNWH Rest Day
        nd_snwh_rd_hr:     times[:nd_snwh_rd_hr],
        nd_snwh_rd_min:    times[:nd_snwh_rd_min],
        nd_snwh_rd_total:  times[:nd_snwh_rd_total],
        nd_snwh_rd_pay:    pays[:nd_snwh_rd],

        # ND OT SNWH Rest Day
        nd_ot_snwh_rd_hr:   times[:nd_ot_snwh_rd_hr],
        nd_ot_snwh_rd_min:  times[:nd_ot_snwh_rd_min],
        nd_ot_snwh_rd_total: times[:nd_ot_snwh_rd_total],
        nd_ot_snwh_rd_pay:  pays[:nd_ot_snwh_rd],

        # ND Regular Holiday
        nd_rh_hr:          times[:nd_rh_hr],
        nd_rh_min:         times[:nd_rh_min],
        nd_rh_total:       times[:nd_rh_total],
        nd_rh_pay:         pays[:nd_rh],

        # ND OT Regular Holiday
        nd_ot_rh_hr:       times[:nd_ot_rh_hr],
        nd_ot_rh_min:      times[:nd_ot_rh_min],
        nd_ot_rh_total:    times[:nd_ot_rh_total],
        nd_ot_rh_pay:      pays[:nd_ot_rh],

        # ND Regular Holiday Rest Day
        nd_rh_rd_hr:       times[:nd_rh_rd_hr],
        nd_rh_rd_min:      times[:nd_rh_rd_min],
        nd_rh_rd_total:    times[:nd_rh_rd_total],
        nd_rh_rd_pay:      pays[:nd_rh_rd],

        # ND OT Regular Holiday Rest Day
        nd_ot_rh_rd_hr:    times[:nd_ot_rh_rd_hr],
        nd_ot_rh_rd_min:   times[:nd_ot_rh_rd_min],
        nd_ot_rh_rd_total: times[:nd_ot_rh_rd_total],
        nd_ot_rh_rd_pay:   pays[:nd_ot_rh_rd],

        # Reimbursements + Summary (always shown)
        reimbursements:    0,
        gross_pay:         payroll.gross_pay.to_f,
        sss_amount:        payroll.sss_amount.to_f,
        sss_loan:          payroll.sss_loan.to_f,
        hdmf_amount:       payroll.hdmf_amount.to_f,
        hdmf_loan:         payroll.hdmf_loan.to_f,
        phic_amount:       payroll.phic_amount.to_f,
        cash_advance:      payroll.cash_advance.to_f,
        rice_deduction:    payroll.rice_deduction.to_f,
        materials_deduction: payroll.materials_deduction.to_f,
        groceries_deduction: payroll.groceries_deduction.to_f,
        late_ut_amount:    payroll.late_ut_amount.to_f,
        total_deductions:  payroll.total_deductions.to_f,
        net_pay:           payroll.net_pay.to_f,
      }
    end

    # --- Step 2: Determine which columns to show ---
    # A column is shown if it's in ALWAYS_SHOW OR at least one employee has a non-zero value
    @active_cols = COL.keys.select do |key|
      ALWAYS_SHOW.include?(key) ||
        buffer.any? { |row| row[key].is_a?(Numeric) && row[key] != 0 }
    end

    # --- Step 3: Write only active columns ---
    buffer.each_with_index do |row_data, idx|
      row_0 = DATA_START_ROW - 1 + idx
      @active_cols.each { |key| write(sheet, row_0, key, row_data[key]) }
      sheet.sheet_data[row_0].ht            = @row10_height
      sheet.sheet_data[row_0].custom_height = true
    end

    write_totals(sheet)
    write_footer(sheet)
  end

  # ---------------------------------------------------------------------------
  # Totals row — sums all numeric columns across employee rows
  # ---------------------------------------------------------------------------
  def write_totals(sheet)
    total_row_0 = DATA_START_ROW - 1 + @payrolls.size
    first_row_0 = DATA_START_ROW - 1
    last_data_0 = total_row_0 - 1

    write(sheet, total_row_0, :name, "TOTAL")

    numeric_keys = @active_cols - %i[name status days_worked daily_rate allowance_per_day reimbursements]

    numeric_keys.each do |col_key|
      col_0 = COL.fetch(col_key) - 1
      total = 0.0
      (first_row_0..last_data_0).each do |r|
        cell = sheet.sheet_data[r]&.[](col_0)
        val  = cell&.value
        total += val.to_f if val.is_a?(Numeric)
      end
      write(sheet, total_row_0, col_key, total.round(2))
    end

    sheet.sheet_data[total_row_0].ht            = @row10_height
    sheet.sheet_data[total_row_0].custom_height = true
  end

  # ---------------------------------------------------------------------------
  # Footer — placed dynamically after last data row
  # ---------------------------------------------------------------------------
  def write_footer(sheet)
    # +1 for the totals row that sits between data and footer
    after_last = DATA_START_ROW - 1 + @payrolls.size + 1

    label_row = after_last + 1
    sig_row   = after_last + 2
    name_row  = after_last + 3
    title_row = after_last + 4

    pb_start_0    = 1    # B (0-based)
    merge_start_0 = 101  # CX (0-based)

    # Write cells first so rows exist in sheet_data
    sheet.add_cell(label_row, pb_start_0,    "Prepared By:")
    sheet.add_cell(label_row, merge_start_0, "Approved  & Released By:")
    sheet.add_cell(name_row,  pb_start_0,    @prepared_by)
    sheet.add_cell(name_row,  merge_start_0, @approved_by)
    sheet.add_cell(title_row, pb_start_0,    @prepared_by_title)
    sheet.add_cell(title_row, merge_start_0, @approved_by_title)
    sheet.add_cell(sig_row,   pb_start_0,    nil)

    # Merge 3 cells on each side using RubyXL's merged_cells collection
    [label_row, name_row, title_row].each do |r|
      # RubyXL uses 0-based row, 0-based col for merged cell refs
      # Format: "A1:C1" style ref using actual Excel 1-based row numbers
      excel_row = r + 1  # convert 0-based to 1-based for the ref string

      pb_col_start = (pb_start_0 + 1).then { |c| col_letter(c) }      # B
      pb_col_end   = (pb_start_0 + 3).then { |c| col_letter(c) }      # D
      mg_col_start = (merge_start_0 + 1).then { |c| col_letter(c) }   # CX
      mg_col_end   = (merge_start_0 + 3).then { |c| col_letter(c) }   # CZ

      sheet.merged_cells ||= []
      sheet.merged_cells << RubyXL::MergedCell.new(ref: "#{pb_col_start}#{excel_row}:#{pb_col_end}#{excel_row}")
      sheet.merged_cells << RubyXL::MergedCell.new(ref: "#{mg_col_start}#{excel_row}:#{mg_col_end}#{excel_row}")
    end

    # Row heights
    [label_row, name_row, title_row].each do |r|
      sheet.sheet_data[r].ht            = @row10_height
      sheet.sheet_data[r].custom_height = true
    end
    sheet.sheet_data[sig_row].ht            = 22
    sheet.sheet_data[sig_row].custom_height = true

    # Style + borders
    footer_style = sheet.sheet_data[16]&.[](1)&.style_index || 0
    [[label_row, pb_start_0], [label_row, merge_start_0],
     [name_row,  pb_start_0], [name_row,  merge_start_0],
     [title_row, pb_start_0], [title_row, merge_start_0]].each do |r, c|
      cell = sheet.sheet_data[r]&.[](c)
      next unless cell
      cell.style_index = footer_style
    end
  end

  # ---------------------------------------------------------------------------
  # Time slice aggregation
  # ---------------------------------------------------------------------------
  def fetch_slices(payroll)
    dtr_ids = payroll.employee
                     .daily_time_records
                     .where(date: payroll.start_date..payroll.end_date)
                     .pluck(:id)
    TimeSlice.where(daily_time_record_id: dtr_ids)
  end

  def compute_times(slices)
    buckets = Hash.new(0)
    slices.each { |s| buckets[slice_bucket_key(s)] += s.minutes.to_i }

    keys = %i[ot rd ot_rd snwh ot_snwh snwh_rd ot_snwh_rd rh rh_rd ot_rh ot_rh_rd
              nd_ord nd_ot nd_rd nd_ot_rd nd_snwh nd_ot_snwh nd_snwh_rd nd_ot_snwh_rd
              nd_rh nd_ot_rh nd_rh_rd nd_ot_rh_rd]

    result = keys.each_with_object({}) do |k, h|
      total = buckets[k]
      h[:"#{k}_hr"]    = total / 60
      h[:"#{k}_min"]   = total % 60
      h[:"#{k}_total"] = (total / 60.0).round(2)
    end

    result
  end

  # ---------------------------------------------------------------------------
  # Pay aggregation — sums slice.pay per bucket
  # ---------------------------------------------------------------------------
  def compute_pays(slices)
    buckets = Hash.new(0.0)
    slices.each { |s| buckets[slice_bucket_key(s)] += s.pay.to_f }
    buckets
  end

  # ---------------------------------------------------------------------------
  # Determines which pay/time bucket a slice belongs to.
  # Uses boolean flags from the slice (reliable) and code string for SNWH/RH
  # detection (hyphens only — codes are generated as "RH", "SNWH", "RH-RD", etc.)
  # ---------------------------------------------------------------------------
  def slice_bucket_key(s)
    code = s.multiplier_code.to_s.upcase
    nd   = s.night_diff?
    ot   = s.overtime?
    rd   = s.rest_day?
    snwh = code.include?("SNWH")
    rh   = !snwh && code.include?("RH")

    if nd
      if    ot && rh && rd   then :nd_ot_rh_rd
      elsif ot && rh         then :nd_ot_rh
      elsif ot && snwh && rd then :nd_ot_snwh_rd
      elsif ot && snwh       then :nd_ot_snwh
      elsif ot && rd         then :nd_ot_rd
      elsif ot               then :nd_ot
      elsif rh && rd         then :nd_rh_rd
      elsif rh               then :nd_rh
      elsif snwh && rd       then :nd_snwh_rd
      elsif snwh             then :nd_snwh
      elsif rd               then :nd_rd
      else                        :nd_ord
      end
    elsif ot
      if    rh && rd   then :ot_rh_rd
      elsif rh         then :ot_rh
      elsif snwh && rd then :ot_snwh_rd
      elsif snwh       then :ot_snwh
      elsif rd         then :ot_rd
      else                  :ot
      end
    elsif rh && rd   then :rh_rd
    elsif rh         then :rh
    elsif snwh && rd then :snwh_rd
    elsif snwh       then :snwh
    elsif rd         then :rd
    else                  :reg
    end
  end

  # ---------------------------------------------------------------------------
  # Hide every COL column that has no data for this period so the sheet is
  # narrow enough to print. @active_cols is set by write_employees.
  # ---------------------------------------------------------------------------
  def hide_inactive_columns(sheet)
    inactive = COL.keys - @active_cols
    inactive.each do |key|
      col_0 = COL.fetch(key) - 1
      range = sheet.cols.get_range(col_0)
      range.hidden       = true
      range.width        = 0
      range.custom_width = true
    end
  end

  # ---------------------------------------------------------------------------
  # write — stamps a value with row 10's cached style
  # Zero numerics show as "-"
  # ---------------------------------------------------------------------------
  def write(sheet, row_0, col_key, value)
    col_0     = COL.fetch(col_key) - 1
    style_idx = @row10_styles[col_0] || @row10_styles[1] || 0
    display   = value.is_a?(Numeric) && value == 0 ? "-" : value

    cell = sheet.add_cell(row_0, col_0, display)
    cell.style_index = style_idx
    cell
  end

  # Returns the employee's scheduled working hours per day (shift minus break).
  # Falls back to 8 if shift times are not configured.
  def shift_hours(employee)
    s = employee.shift_start_time
    e = employee.shift_end_time
    return 8.0 unless s && e

    e += 24 * 3600 if e <= s  # overnight shift
    total = e - s

    bs = employee.break_start_time
    be = employee.break_end_time
    if bs && be
      be += 24 * 3600 if be <= bs
      total -= (be - bs)
    end

    (total / 3600.0).round(2)
  end

  # Converts 1-based column number to Excel letter(s): 1→A, 26→Z, 27→AA, etc.
  def col_letter(col_1based)
    result = ""
    n = col_1based
    while n > 0
      n, rem = (n - 1).divmod(26)
      result = (65 + rem).chr + result
    end
    result
  end
end
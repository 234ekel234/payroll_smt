# Codebase Fixes & Improvements

## ✅ Done

### 1. Overtime minutes never saved to DTR
- **File:** `app/models/daily_time_record.rb:31`
- **Fix:** Changed `summary[:ot_minutes]` → `summary[:overtime_minutes]` to match the key returned by `TimeSlicerService#summarize`.

### 2. Night differential calculated on wrong base rate
- **File:** `app/services/payroll_generator.rb:66`
- **Fix:** Changed `hourly_rate * 0.10` → `hourly_rate * multiplier * 0.10` so night diff is 10% of the applicable rate (OT, holiday, etc.) rather than always 10% of the base rate. DOLE-compliant.

---

## 🔲 To Do

### ✅ 3. Rest day check false-positive on `include?("RD")`
- **File:** `app/services/payroll_generator.rb:53`
- **Fix:** Changed to `multiplier_code&.split("-")&.include?("RD")` for exact token matching.

### ✅ 4. SSS bracket range gaps in seeds
- **File:** `db/seeds/gov_deductions.rb`
- **Fix:** First bracket now starts at `range_min: 0`, subsequent brackets use `range_min: msc - 250.0` and `range_max: msc + 249.99` — fully contiguous, no gaps.

### ✅ 5. No validation on `basic_rate`
- **File:** `app/models/employee.rb`
- **Fix:** Added `validates :basic_rate, presence: true, numericality: { greater_than: 0 }`.

### ✅ 6. No validations on `Payroll`
- **File:** `app/models/payroll.rb`
- **Fix:** Added `validates :start_date, :end_date, :gross_pay, presence: true`.

### ✅ 7. Dead columns — `early_leave_minutes` and `early_leave`
- **Files:** `db/migrate/20260517000001_remove_early_leave_columns.rb`
- **Fix:** Migration created to drop `early_leave_minutes` from `daily_time_records` and `early_leave` from `time_slices`. Run `bin/rails db:migrate` to apply.

### ✅ 8. Fixture type mismatch for time columns
- **File:** `test/fixtures/employees.yml`
- **Fix:** Changed `shift_start/end`, `break_start/end` to time-only format (`"08:00:00"`). Also gave fixtures realistic names, unique `person_id`s, and proper `work_days` array values.

### ✅ 9. Empty test suite
- **Files:** `test/models/employee_test.rb`, `test/models/payroll_test.rb`, `test/models/time_slicer_service_test.rb`
- **Fix:** Wrote real tests covering: Employee validations and shift template resolution, Payroll `calculate_final_amounts!` and net_pay floor, and TimeSlicerService for regular shifts, late arrival, grace period, OT threshold, night diff, early clock-in clipping, holiday tagging, and missing-shift guard.

---

## 🔲 New Issues Found

### ✅ 10. `TimeSlice.pay` never populated — Excel summary pay breakdown always 0
- **File:** `app/services/payroll_generator.rb`, `app/services/excel_summary_generator.rb:615`
- **Issue:** `ExcelSummaryGenerator#compute_pays` sums `s.pay` per slice for the detailed pay breakdown (OT rest day, SNWH, regular holiday, etc.), but `TimeSlicerService` never sets the `pay` column when building slices. Every detailed pay bucket in the Excel summary is always 0.
- **Fix:** In `PayrollGenerator#process_employee`, after computing `slice_money` for each slice, call `slice.update_column(:pay, slice_money.round(2))`.

### 11. Hardcoded signatory names in `ExcelSummaryGenerator`
- **File:** `app/services/excel_summary_generator.rb:178`
- **Issue:** `prepared_by` and `approved_by` default to hardcoded names ("Elaine Beatriz C. Bello", "Ms. Winalene E. Sescar"). These should be configurable.
- **Fix:** Move to Rails credentials or a config/settings table so they can be changed without a code deploy.

### ✅ 12. Hardcoded fallback company name in `ExcelPayrollGenerator`
- **File:** `app/services/excel_payroll_generator.rb:37`
- **Issue:** When a payroll's company is `"default"`, the payslip header falls back to the hardcoded string `"Facilities Managers, Inc."`.
- **Fix:** Move the fallback to Rails credentials or an ENV variable.

### ✅ 13. Incomplete deductions seed
- **File:** `db/seeds/deductions.rb`
- **Issue:** Only SSS, PHIC, and HDMF statutory deductions are seeded. No standard deductions (loans, uniforms, rice allowance, etc.) are seeded, so users must create everything manually from scratch.
- **Fix:** Seed a standard set of common deductions as inactive defaults that users can activate.

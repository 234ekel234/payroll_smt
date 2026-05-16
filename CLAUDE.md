# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Development (local, non-Docker):**
```bash
bin/dev                        # Start Rails + Dart Sass watcher (via Procfile.dev)
bin/rails server               # Rails only
bin/rails dartsass:watch       # CSS watcher only
```

**Database:**
```bash
bin/rails db:prepare           # Create, migrate, and seed
bin/rails db:migrate
bin/rails db:seed
```

**Tests:**
```bash
bin/rails test                             # All tests
bin/rails test test/models/payroll_test.rb # Single file
bin/rails test test/models/payroll_test.rb:42  # Single test by line
```

**Linting:**
```bash
bundle exec rubocop             # Check style (inherits rubocop-rails-omakase)
bundle exec rubocop -a          # Auto-fix safe offenses
```

**Docker (client/production deployment):**
```bash
docker compose up -d
docker compose exec web rails db:prepare   # First-time only
docker compose pull web && docker compose up -d  # Upgrade
```

Ruby version: **3.2.2** (see `.ruby-version`). Rails 8.1, PostgreSQL 16.

## Architecture

### Core Payroll Pipeline

The payroll calculation follows a strict pipeline:

1. **DTR Import** — `DailyTimeRecordImporter` ingests attendance from an Excel/CSV file or Google Sheets (via service account at `config/google_service_account.json`). Each row is matched to an `Employee` by `person_id`. The expected column order is: `person_id, fname, lname, date (MM/DD/YYYY), clock_in, clock_out`.

2. **Time Slicing** — Saving a `DailyTimeRecord` triggers `TimeSlicerService` via `before_save`. The service splits a clock-in/clock-out span into typed segments (regular, overtime, night differential, holiday, rest day) by inserting boundary points at shift start/end, break start/end, 22:00, 06:00, and midnight. Each segment becomes a `TimeSlice` record with a `multiplier_code` (e.g. `RH`, `SNWH-RD-OT`, `OD-OT`) looked up from `PayMultiplier`.

3. **Payroll Generation** — `PayrollGenerator` (called from `PayrollsController#generate`) iterates over employees, reads their `TimeSlice` records for the period, applies each slice's `multiplier_percent` to compute `basic_pay / overtime_pay / holiday_pay / rest_day_pay / night_diff_pay`, and creates a `Payroll` record in `status: 'draft'`.

4. **Deduction Application** — `Payroll#apply_all_deductions` handles two kinds:
   - *Standard* (`PayrollDeduction` with `note: "Standard Deduction"`) — fixed-amount `Deduction` records linked per employee.
   - *Statutory* (SSS, PhilHealth/PHIC, Pag-IBIG/HDMF) — computed by `PayrollCalculator` against `GovDeductionBracket` salary tables. Statutory items also create `PayrollDeduction` rows with `note: "Statutory"` for audit display, but are **excluded** from the line-item sum to prevent double-counting (the amounts live in dedicated columns: `sss_amount`, `phic_amount`, `hdmf_amount`).

5. **Excel/PDF Output** — `ExcelPayrollGenerator` and `ExcelSummaryGenerator` produce `.xlsx` payslips using a company-specific template from `lib/templates/`. PDF payslips use Grover (headless Chrome) to render the `payrolls/show` view with layout `pdf`.

### Key Models and Relationships

```
Shift (template)
  └── Employee (belongs_to :shift, optional)
        ├── DailyTimeRecord
        │     └── TimeSlice (typed segment with multiplier_code, minutes, pay flags)
        ├── Payroll
        │     └── PayrollDeduction (snapshot of each deduction at generation time)
        └── EmployeeDeduction → Deduction (permanent defaults)

PayMultiplier  — codes like REGULAR, OD-OT, RH, SNWH-RD-OT; drives multiplier_percent
GovDeductionBracket — SSS/PhilHealth/Pag-IBIG salary bracket tables (enum: sss/philhealth/pagibig)
Holiday — date + holiday_type ("regular" | "special non-working")
```

### Shift Resolution (Two-Level)

`Employee` has its own `shift_start/shift_end/break_start/break_end` columns **and** an optional `belongs_to :shift` (the `Shift` template). The helpers `effective_shift_start`, `shift_start_time`, `break_start_time`, etc. check the template first and fall back to the employee's own columns. `TimeSlicerService` always goes through these helpers, so individual overrides work correctly.

### SSS Base Salary Logic

SSS contributions use **last month's actual gross** (pulled from the `Payroll` table) as the contribution base. If no prior payroll exists (new hire), it falls back to `basic_rate * 26`. This is handled in `PayrollCalculator#lookup_past_payroll_gross`.

### Important Invariants

- **Time zone**: All time parsing is done in `Asia/Manila`. `TimeSlicerService#normalize_time` pins shift times to the DTR date in `Time.zone` to avoid "Year 2000" drift from `time` columns.
- **Overnight shifts**: Both the importer and `DailyTimeRecord#fix_overnight_clock_out` add `1.day` to `clock_out` when it is ≤ `clock_in`.
- **Overtime grace**: 30 minutes past shift end required before overtime is counted (`OVERTIME_GRACE_MINUTES = 30`).
- **Late grace**: 5 minutes (`LATE_GRACE_MINUTES = 5`).
- **Re-generation**: `PayrollGenerator` deletes existing `draft` payrolls for the same employee+period before recreating, making it safe to re-run.
- **Double-counting guard**: `Payroll#calculate_final_amounts!` sums `payroll_deductions WHERE note != 'Statutory'` so statutory line items (audit only) are never added twice.

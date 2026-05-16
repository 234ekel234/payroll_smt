# Payroll System

A Rails 8 payroll management system for Philippine-based businesses. Handles employee attendance (DTR), automatic time slicing with pay multipliers (overtime, night differential, holidays, rest days), payroll generation, statutory deductions (SSS, PhilHealth, Pag-IBIG), and Excel/PDF payslip exports.

---

## Developer Setup

### Prerequisites

- Ruby 3.2.2
- PostgreSQL 16
- Node.js (for Dart Sass)

### Getting Started

```bash
bundle install
cp .env.example .env        # fill in RAILS_MASTER_KEY and DB password
bin/rails db:prepare        # create, migrate, seed
bin/dev                     # starts Rails + Dart Sass watcher
```

App runs at `http://localhost:3000`.

### Running Tests

```bash
bin/rails test                                      # all tests
bin/rails test test/models/payroll_test.rb          # single file
bin/rails test test/models/payroll_test.rb:42       # single test
```

### Linting

```bash
bundle exec rubocop       # check
bundle exec rubocop -a    # auto-fix
```

---

## Architecture Overview

The core payroll pipeline runs in four stages:

1. **DTR Import** — `DailyTimeRecordImporter` reads attendance from an Excel/CSV file or Google Sheets. Each row is matched to an employee by `person_id`. Expected columns: `person_id, first_name, last_name, date (MM/DD/YYYY), clock_in, clock_out`.

2. **Time Slicing** — Saving a `DailyTimeRecord` triggers `TimeSlicerService`. It splits the clock-in/out span into typed segments by inserting boundary points at shift start/end, break start/end, 22:00, 06:00, and midnight. Each segment becomes a `TimeSlice` with a `multiplier_code` (e.g. `REGULAR`, `RH`, `SNWH-RD-OT`) resolved from the `PayMultiplier` table.

3. **Payroll Generation** — `PayrollGenerator` reads `TimeSlice` records for a date range, applies each slice's `multiplier_percent` to compute pay buckets (`basic_pay`, `overtime_pay`, `holiday_pay`, `rest_day_pay`, `night_diff_pay`), and creates a `Payroll` record with `status: 'draft'`. Re-running for the same period safely replaces existing drafts.

4. **Deductions** — `Payroll#apply_all_deductions` applies standard deductions (fixed amounts per employee) and statutory deductions (SSS, PhilHealth/PHIC, Pag-IBIG/HDMF) computed by `PayrollCalculator` against `GovDeductionBracket` salary tables. SSS uses last month's actual gross from the `Payroll` table, falling back to `basic_rate × 26` for new hires.

**Exports** — `ExcelPayrollGenerator` fills company-specific `.xlsx` templates from `lib/templates/`. PDF payslips use Grover (headless Chrome) to render the payslip view.

---

## Client Setup (Docker)

This setup uses **Docker** to run the Rails app and Postgres 16 database. No source code or Ruby installation is required.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (includes Docker Compose)

### 1. Environment Variables

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

```env
RAILS_MASTER_KEY=<provided by your vendor>
PAYROLL_SYSTEM_DATABASE_PASSWORD=secret123
```

### 2. Start the Application

```bash
docker compose up -d
```

Docker pulls the Rails image from Docker Hub and the official Postgres image automatically. Containers restart automatically on system reboot.

### 3. First-Time Database Setup

Run once after the first `docker compose up`:

```bash
docker compose exec web rails db:prepare
```

### 4. Access the App

`http://localhost:3000`

### 5. Stop the App

```bash
docker compose down
```

Postgres data is persisted in the `postgres_data` volume and will not be lost.

### 6. Update the App

When a new version is available on Docker Hub:

```bash
docker compose pull web
docker compose up -d
```

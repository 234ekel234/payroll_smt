# db/seeds/deductions.rb
puts "Seeding Master Deduction Templates (UI Records)..."
Deduction.destroy_all

# --- Statutory (amounts computed dynamically from GovDeductionBracket) ---
[
  { name: 'SSS',  notes: 'Social Security System' },
  { name: 'PHIC', notes: 'PhilHealth Insurance' },
  { name: 'HDMF', notes: 'Pag-IBIG Fund' }
].each do |item|
  Deduction.create!(
    name: item[:name],
    category: 'Statutory',
    active: true,
    notes: item[:notes],
    amount: 0.0,
    amount_type: 'fixed'
  )
end

# --- Loans ---
[
  { name: 'SSS Loan',   notes: 'SSS salary loan repayment',  amount: 0.0 },
  { name: 'Pag-IBIG Loan', notes: 'HDMF multi-purpose loan repayment', amount: 0.0 },
  { name: 'Company Cash Advance', notes: 'Cash advance against salary', amount: 0.0 },
].each do |item|
  Deduction.create!(
    name: item[:name],
    category: 'Loan',
    active: true,
    notes: item[:notes],
    amount: item[:amount],
    amount_type: 'fixed'
  )
end

# --- Standard Deductions ---
[
  { name: 'Rice Allowance Deduction', notes: 'Monthly rice subsidy deduction', amount: 0.0 },
  { name: 'Uniform Deduction',        notes: 'Uniform amortization',           amount: 0.0 },
  { name: 'Materials Deduction',      notes: 'Tools or materials provided',    amount: 0.0 },
  { name: 'Groceries Deduction',      notes: 'Grocery benefit deduction',      amount: 0.0 },
  { name: 'Late/Undertime',           notes: 'Deduction for late or undertime minutes', amount: 0.0 },
].each do |item|
  Deduction.create!(
    name: item[:name],
    category: 'Standard',
    active: false,
    notes: item[:notes],
    amount: item[:amount],
    amount_type: 'fixed'
  )
end
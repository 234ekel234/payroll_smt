GovDeductionBracket.destroy_all

puts "Seeding 2026 Government Brackets..."

# --- SSS 2026 (15% Total: 5% Employee Share) ---
# Min MSC: 5,000 | Max MSC: 35,000
(5000..34500).step(500).each do |msc|
  GovDeductionBracket.create!(
    deduction_type: :sss,
    range_min: msc - 250,
    range_max: msc + 249.99,
    amount: msc * 0.05 # 5% Employee Share
  )
end
# Max SSS Bracket
GovDeductionBracket.create!(deduction_type: :sss, range_min: 34750, range_max: 999999, amount: 1750.00)

# --- PhilHealth 2026 (5% Total: 2.5% Employee Share) ---
# Floor: 10k | Ceiling: 100k
GovDeductionBracket.create!(deduction_type: :philhealth, range_min: 0, range_max: 10000, amount: 250.00)
# For salaries between 10k and 100k, the amount is calculated as Gross * 0.025
# We can represent this with a high-level bracket or handle in model logic.
GovDeductionBracket.create!(deduction_type: :philhealth, range_min: 10000.01, range_max: 99999.99, amount: 0) 
GovDeductionBracket.create!(deduction_type: :philhealth, range_min: 100000, range_max: 999999, amount: 2500.00)

# --- Pag-IBIG 2026 (Max Salary Cap: 10,000) ---
GovDeductionBracket.create!(deduction_type: :pagibig, range_min: 0, range_max: 1500, amount: 15.00)
GovDeductionBracket.create!(deduction_type: :pagibig, range_min: 1500.01, range_max: 999999, amount: 200.00)

puts "Government Brackets Seeded Successfully!"
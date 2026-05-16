# db/seeds/gov_deductions.rb
puts "Cleaning and Seeding Government Brackets (Math Logic)..."
GovDeductionBracket.destroy_all

# SSS 2026 Logic
# Ranges are contiguous: first bracket starts at 0, each subsequent bracket
# starts at the previous bracket's max + 0.01 (i.e. msc - 250).
(5000..35000).step(500).each_with_index do |msc, i|
  GovDeductionBracket.create!(
    deduction_type: :sss,
    range_min: i == 0 ? 0 : msc - 250.0,
    range_max: msc + 249.99,
    amount: (msc * 0.05).round(2)
  )
end

# PhilHealth Logic (Range triggers)
GovDeductionBracket.create!(deduction_type: :philhealth, range_min: 0, range_max: 10000, amount: 250.0)
GovDeductionBracket.create!(deduction_type: :philhealth, range_min: 10000.01, range_max: 99999.99, amount: 0) 
GovDeductionBracket.create!(deduction_type: :philhealth, range_min: 100000, range_max: 9999999, amount: 2500.0)

# Pag-IBIG Logic
# Lower bracket: amount 0 signals 1% of salary (calculated dynamically)
# Upper bracket: 2% of salary, capped at ₱200
GovDeductionBracket.create!(deduction_type: :pagibig, range_min: 0,       range_max: 1500,   amount: 0.0)
GovDeductionBracket.create!(deduction_type: :pagibig, range_min: 1500.01, range_max: 999999, amount: 200.0)
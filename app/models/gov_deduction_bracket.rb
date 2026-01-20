class GovDeductionBracket < ApplicationRecord
  enum :deduction_type, { sss: 0, philhealth: 1, pagibig: 2 }

  def self.calculate_amount(name, gross_pay)
    type_key = name.to_s.downcase.to_sym
    return 0.0 unless deduction_types.key?(type_key)
    return 0.0 if gross_pay <= 0

    # 1. Look for the matching bracket in the DB
    bracket = where(deduction_type: type_key)
              .where("range_min <= ? AND range_max >= ?", gross_pay, gross_pay)
              .first

    # 2. Handle Case: Salary exceeds the highest bracket
    if bracket.nil?
      max_bracket = where(deduction_type: type_key).order(range_max: :desc).first
      return max_bracket.amount.to_f if max_bracket && gross_pay > max_bracket.range_min
      return 0.0
    end

    # 3. Handle Case: Percentage-based (PhilHealth Middle Tier)
    # If the amount is 0, it signals a formula calculation
    if type_key == :philhealth && bracket.amount.to_f == 0.0
      return (gross_pay * 0.025).round(2)
    end

    bracket.amount.to_f
  end
end
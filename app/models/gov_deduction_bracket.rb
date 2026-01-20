class GovDeductionBracket < ApplicationRecord
  # Fix: Added a colon before deduction_type and a comma after
  enum :deduction_type, { sss: 0, philhealth: 1, pagibig: 2}

  def self.calculate_amount(name, gross_pay)
    type_key = name.downcase.to_sym
    return 0 unless deduction_types.key?(type_key)

    bracket = where(deduction_type: type_key)
              .where("range_min <= ? AND range_max >= ?", gross_pay, gross_pay)
              .first

    bracket&.amount || 0
  end
end
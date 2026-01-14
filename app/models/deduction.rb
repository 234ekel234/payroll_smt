class Deduction < ApplicationRecord
  # Updated syntax to be more explicit
  enum :amount_type, { fixed: 0, percentage: 1 }

  def calculate_for(gross_amount)
    return 0.0 if amount.nil?

    # Rails automatically provides the 'percentage?' method from the enum above
    if percentage?
      (gross_amount.to_f * (amount.to_f / 100.0)).round(2)
    else
      amount.to_f
    end
  end
end
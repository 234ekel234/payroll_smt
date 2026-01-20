class Deduction < ApplicationRecord
  # Relationships
  has_many :employee_deductions, dependent: :destroy
  has_many :employees, through: :employee_deductions
  has_many :payroll_deductions # No dependent: :destroy to protect history

  # Enums
  enum :amount_type, { fixed: 0, percentage: 1 }

  # Callbacks
  before_save :normalize_name

  # Scopes
  scope :active, -> { where(active: true) }
  scope :archived, -> { where(active: false) }

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :amount_type, presence: true

  # NEW: Professional Safety Rails
  validate :name_is_not_generic

  def calculate_for(gross_amount)
    return 0.0 if amount.nil? || !active?

    calculated_amount = if percentage?
                          (gross_amount.to_f * (amount.to_f / 100.0))
                        else
                          amount.to_f
                        end

    [calculated_amount, 0].max.round(2)
  end

  def formatted_amount
    if percentage?
      "#{amount}%"
    else
      "₱#{ActionController::Base.helpers.number_with_precision(amount, precision: 2)}"
    end
  end

  private

  # 1. Prevent "Dummy" data names
  def name_is_not_generic
    blacklisted_names = ["deduction", "statutory share", "statutory", "test", "temp", "dummy"]
    if blacklisted_names.include?(name.to_s.downcase.strip)
      errors.add(:name, "is too generic. Please use a specific name (e.g., 'SSS Contribution' or 'Uniform Loan')")
    end
  end

  # 2. Automatically Clean up names (e.g., "sss" becomes "SSS" or "uniform" becomes "Uniform")
  def normalize_name
    self.name = name.strip.titleize
    # Special case for Acronyms
    self.name = "SSS" if name.downcase == "Sss"
    self.name = "HDMF (Pag-IBIG)" if name.downcase.include?("pag-ibig") || name.downcase == "hdmf"
  end
end
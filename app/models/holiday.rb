class Holiday < ApplicationRecord
  validates :name, :date, :holiday_type, presence: true
  validates :date, uniqueness: { message: "already has a holiday" }

  before_save :normalize_holiday_type

  TYPES = ["regular", "special non-working"].freeze

  validates :holiday_type, inclusion: { in: TYPES }

  private

  def normalize_holiday_type
    self.holiday_type = holiday_type.to_s.downcase.strip
  end
end

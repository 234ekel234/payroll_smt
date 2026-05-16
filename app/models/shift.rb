class Shift < ApplicationRecord
  has_many :employees
  validates :name, :shift_start, :shift_end, presence: true
end
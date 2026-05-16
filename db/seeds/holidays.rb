# db/seeds.rb

Holiday.destroy_all

puts "Seeding Philippine Holidays for 2026..."

holidays = [
  # =========================
  # Regular Holidays
  # =========================
  { date: "2026-01-01", name: "New Year's Day", holiday_type: "regular", applies_to: "all", notes: "Paid holiday for all employees" },
  { date: "2026-04-02", name: "Maundy Thursday", holiday_type: "regular", applies_to: "all", notes: "Holy Week holiday" },
  { date: "2026-04-03", name: "Good Friday", holiday_type: "regular", applies_to: "all", notes: "Holy Week holiday" },
  { date: "2026-04-09", name: "Araw ng Kagitingan (Day of Valor)", holiday_type: "regular", applies_to: "all", notes: "Commemorates Filipino soldiers in WWII" },
  { date: "2026-05-01", name: "Labor Day", holiday_type: "regular", applies_to: "all", notes: "Paid holiday for all employees" },
  { date: "2026-06-12", name: "Independence Day", holiday_type: "regular", applies_to: "all", notes: "Philippine Independence from Spain (1898)" },
  { date: "2026-08-31", name: "National Heroes Day", holiday_type: "regular", applies_to: "all", notes: "Last Monday of August" },
  { date: "2026-11-30", name: "Bonifacio Day", holiday_type: "regular", applies_to: "all", notes: "Birth anniversary of Andres Bonifacio" },
  { date: "2026-12-25", name: "Christmas Day", holiday_type: "regular", applies_to: "all", notes: "Paid holiday for all employees" },
  { date: "2026-12-30", name: "Rizal Day", holiday_type: "regular", applies_to: "all", notes: "Commemorates Dr. Jose Rizal" },

  # =========================
  # Special Non-Working Holidays
  # =========================
  { date: "2026-02-17", name: "Chinese New Year", holiday_type: "special non-working", applies_to: "all", notes: "Lunar New Year celebration" },
  { date: "2026-04-04", name: "Black Saturday", holiday_type: "special non-working", applies_to: "all", notes: "Holy Week observance" },
  { date: "2026-08-21", name: "Ninoy Aquino Day", holiday_type: "special non-working", applies_to: "all", notes: "Death anniversary of Benigno Aquino Jr." },
  { date: "2026-11-01", name: "All Saints' Day", holiday_type: "special non-working", applies_to: "all", notes: "Christian observance" },
  { date: "2026-11-02", name: "All Souls' Day", holiday_type: "special non-working", applies_to: "all", notes: "Additional special holiday for remembrance" },
  { date: "2026-12-08", name: "Feast of the Immaculate Conception", holiday_type: "special non-working", applies_to: "all", notes: "Catholic feast day" },
  { date: "2026-12-24", name: "Christmas Eve", holiday_type: "special non-working", applies_to: "all", notes: "Additional holiday before Christmas" },
  { date: "2026-12-31", name: "Last Day of the Year", holiday_type: "special non-working", applies_to: "all", notes: "New Year's Eve" },

  # =========================
  # Movable Islamic Holidays (2026 estimated dates — confirm with official proclamation)
  # =========================
  { date: "2026-03-31", name: "Eid'l Fitr (Feast of Ramadhan)", holiday_type: "regular", applies_to: "all", notes: "End of Ramadhan fasting period. Date subject to official proclamation." },
  { date: "2026-06-07", name: "Eid'l Adha (Feast of Sacrifice)", holiday_type: "regular", applies_to: "all", notes: "Feast of the Sacrifice. Date subject to official proclamation." },
]

holidays.each do |h|
  Holiday.create!(h)
end

puts "Philippine holidays seeded successfully!"
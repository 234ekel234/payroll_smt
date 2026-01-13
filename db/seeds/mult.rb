PayMultiplier.delete_all

PayMultiplier.create!([
    # BASE REGULAR DAY
  # ========================
  {
    code: "REGULAR",
    name: "Regular Work",
    holiday_type: "none",
    rest_day: false,
    overtime: false,
    base_multiplier: 1.00
  },
  # ========================
  # ORDINARY DAY
  # ========================
  {
    code: "OD-OT",
    name: "Overtime Pay",
    holiday_type: "none",
    rest_day: false,
    overtime: true,
    base_multiplier: 1.25
  },

  # ========================
  # REST DAY
  # ========================
  {
    code: "RD",
    name: "Rest Day Pay",
    holiday_type: "none",
    rest_day: true,
    overtime: false,
    base_multiplier: 1.30
  },
  {
    code: "RD-OT",
    name: "OT - Rest Day Pay",
    holiday_type: "none",
    rest_day: true,
    overtime: true,
    base_multiplier: 1.69
  },

  # ========================
  # SPECIAL NON-WORKING HOLIDAY
  # ========================
  {
    code: "SNWH",
    name: "Special Non-Working Holiday Pay",
    holiday_type: "special",
    rest_day: false,
    overtime: false,
    base_multiplier: 1.30
  },
  {
    code: "SNWH-OT",
    name: "OT - Special Non-Working Holiday Pay",
    holiday_type: "special",
    rest_day: false,
    overtime: true,
    base_multiplier: 1.69
  },
  {
    code: "SNWH-RD",
    name: "Special Non-Working Holiday on Rest Day",
    holiday_type: "special",
    rest_day: true,
    overtime: false,
    base_multiplier: 1.50
  },
  {
    code: "SNWH-RD-OT",
    name: "OT - Special Non-Working Holiday on Rest Day",
    holiday_type: "special",
    rest_day: true,
    overtime: true,
    base_multiplier: 1.95
  },

  # ========================
  # REGULAR HOLIDAY
  # ========================
  {
    code: "RH-NW",
    name: "Regular Holiday Pay (Not Worked)",
    holiday_type: "regular",
    rest_day: false,
    overtime: false,
    base_multiplier: 2.00
  },
  {
    code: "RH",
    name: "Regular Holiday Pay",
    holiday_type: "regular",
    rest_day: false,
    overtime: false,
    base_multiplier: 2.00
  },
  {
    code: "RH-OT",
    name: "OT - Regular Holiday Pay",
    holiday_type: "regular",
    rest_day: false,
    overtime: true,
    base_multiplier: 2.60
  },
  {
    code: "RH-RD",
    name: "Regular Holiday on Rest Day",
    holiday_type: "regular",
    rest_day: true,
    overtime: false,
    base_multiplier: 2.60
  },
  {
    code: "RH-RD-OT",
    name: "OT - Regular Holiday on Rest Day",
    holiday_type: "regular",
    rest_day: true,
    overtime: true,
    base_multiplier: 3.38
  }
])

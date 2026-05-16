# db/seeds/employees.rb

puts "Cleaning existing records..."
Employee.destroy_all

WORK_DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

employees_data = [
  # --- San Mariano Trading ---
  { person_id: "EMP002", name: "SESCAR, Jonathan", company: "San Mariano Trading", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: true },
  { person_id: "EMP004", name: "GONZALES, Rodel", company: "San Mariano Trading", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: true },
  { person_id: "EMP007", name: "ANTENOR, Benedicto", company: "San Mariano Trading", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: true },
  { person_id: "EMP011", name: "SINAGPULO, Jacinto", company: "San Mariano Trading", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: true },
  { person_id: "EMP112", name: "FALCUNITIN, Rommel M.", company: "San Mariano Trading", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },

  # --- Southern Mindoro Traders and Builders Depot ---
  { person_id: "EMP031", name: "SESCAR, Janilon", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP033", name: "RACELIS, Roberto", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP038", name: "GALANGGALANG, Erwin", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP039", name: "GALANGGALANG, Nicanor", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP040", name: "JARABE, Dennis", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP041", name: "JARABE, Gene Eric", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP042", name: "MAÑEJE, Jonrich", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP043", name: "MUTYA, Maridel", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP044", name: "SESCAR, Jeeve", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP045", name: "SESCAR, Joverlyn", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "07:00", shift_end: "16:00", landbank_atm: false },
  { person_id: "EMP034", name: "BERBANO, Michael", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP035", name: "DELOS REYES, Cris", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP036", name: "GABAYNO, Ryan", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP037", name: "GAJONERA, Maria Ana Gay", company: "Southern Mindoro Traders and Builders Depot", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },

  # --- MOTORPOOL ---
  { person_id: "EMP009", name: "GADO, Jeremy", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP012", name: "MARIANO, Jayson", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP013", name: "GADO, Charles", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP014", name: "ABREO, Alberto", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP016", name: "ABREO, Arnold", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP018", name: "GADON, Ronald", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP019", name: "ABEJO, Reynaldo", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP020", name: "MERQUE, Rolly", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP021", name: "GADO, Laurence", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP022", name: "ANONUEVO, Erick", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP026", name: "LAGMAY, Roujebert", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP027", name: "GADO, Jay", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP028", name: "GADO, Marvin", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP050", name: "GADO, Kevin", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP060", name: "SOLABO, Jevan", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP061", name: "GUSI, Xander", company: "MOTORPOOL", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },

  # --- GRAVEL & SAND ---
  { person_id: "EMP008", name: "YATCO, Avelino", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP010", name: "CASAO, Omar", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: true },
  { person_id: "EMP084", name: "MARCELO, Ceejay V.", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP086", name: "LAOMOC, Apolinario P.", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP098", name: "BARCENA, Noly Boy G.", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP103", name: "BELLO, Benedict M.", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP104", name: "BELLO, Mark M.", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP108", name: "FAMISARAN, Floyd J.", company: "GRAVEL & SAND", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: true },

  # --- DJWA / HOME ---
  { person_id: "EMP063", name: "DAGUNO JR., Nestor G.", company: "DJWA Enterprises and Home", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP067", name: "MAGADA, Bercelle G.", company: "DJWA Enterprises and Home", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP068", name: "MORENO, Bobby D.", company: "DJWA Enterprises and Home", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP069", name: "PERADILLA, Ruel G.", company: "DJWA Enterprises and Home", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP100", name: "FORMILOS, Efren B.", company: "DJWA Enterprises and Home", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP101", name: "FROGOSA SR., Roel O.", company: "DJWA Enterprises and Home", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },

  # --- SMT PROPERTIES ---
  { person_id: "EMP005", name: "SESCAR, Esteban", company: "SMT PROPERTIES", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP074", name: "BELLO, Elaine Beatriz C.", company: "SMT PROPERTIES", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP075", name: "CASTILLO, Kier Altea M.", company: "SMT PROPERTIES", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP078", name: "JUAYNO, Jiecel S.", company: "SMT PROPERTIES", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP079", name: "FORIO, Maycel D.", company: "SMT PROPERTIES", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP080", name: "CASTILLO, Allyza M.", company: "SMT PROPERTIES", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },

  # --- PHARMACARE ---
  { person_id: "EMP064", name: "TAYTAY, Roselyn T.", company: "PHARMACARE", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },
  { person_id: "EMP065", name: "GONZALES, Rosalie C.", company: "PHARMACARE", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: true },
  { person_id: "EMP066", name: "FERNANDEZ, Jessa S.", company: "PHARMACARE", basic_rate: 500, allowance_per_day: 0, shift_start: "08:00", shift_end: "17:00", landbank_atm: false },

  # --- JUSTWIN ---
  { person_id: "EMP006", name: "CONSULTA, Alex", company: "JUSTWIN", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: true },
  { person_id: "EMP077", name: "ATIENZA, Ronalyn N.", company: "JUSTWIN", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },

  # --- A&W (12-Hour Shifts) ---
  { person_id: "EMP113", name: "ARANDIA, Rico T.", company: "A&W", basic_rate: 500, allowance_per_day: 0, shift_start: "06:00", shift_end: "18:00", landbank_atm: true },
  { person_id: "EMP114", name: "MAGADA, Pedmar G.", company: "A&W", basic_rate: 500, allowance_per_day: 0, shift_start: "06:00", shift_end: "18:00", landbank_atm: true },
  { person_id: "EMP115", name: "MERCADO, Mary Grace T.", company: "A&W", basic_rate: 500, allowance_per_day: 0, shift_start: "06:00", shift_end: "18:00", landbank_atm: true },
  { person_id: "EMP116", name: "SELLES, Joey M.", company: "A&W", basic_rate: 500, allowance_per_day: 0, shift_start: "06:00", shift_end: "18:00", landbank_atm: true },

  # --- HOUSEKEEPERS ---
  { person_id: "EMP015", name: "YATCO, Ester", company: "HOUSEKEEPERS", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP059", name: "GADO, Nenita", company: "HOUSEKEEPERS", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },

  # --- PROBITIONARY / VARIOUS ---
  { person_id: "EMP082", name: "FADRI, Mildred A.", company: "PROBITIONARY", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP083", name: "CASTILLO, John Kennete D.", company: "PROBITIONARY", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP085", name: "BASILAN III, Cresencio F.", company: "PROBITIONARY", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP091", name: "DE CHAVEZ, Lawrence F.", company: "PROBITIONARY", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false },
  { person_id: "EMP094", name: "SANTIAGO, Ephraim", company: "PROBITIONARY", basic_rate: 500, allowance_per_day: 0, shift_start: "07:30", shift_end: "16:30", landbank_atm: false }
]

employees_data.each do |data|
  # Using find_or_initialize_by is safer for repeated seed runs
  employee = Employee.find_or_initialize_by(person_id: data[:person_id])
  employee.assign_attributes(
    name:                 data[:name],
    company:              data[:company],
    basic_rate:           data[:basic_rate],
    allowance_per_day:    data[:allowance_per_day],
    shift_start:          Time.zone.parse(data[:shift_start]),
    shift_end:            Time.zone.parse(data[:shift_end]),
    break_start:          Time.zone.parse("12:00"),
    break_end:            Time.zone.parse("13:00"),
    schedule:             "Regular",
    status_of_employment: "Active",
    landbank_atm:         data[:landbank_atm],
    work_days:            WORK_DAYS
  )
  employee.save!
  puts "Seeded: #{employee.person_id} - #{employee.name}"
end

puts "Success! Total employees: #{Employee.count}"
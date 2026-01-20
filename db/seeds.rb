puts "Seeding employees..."
load Rails.root.join("db/seeds/employees.rb")
puts "Seeding holidays..."
load Rails.root.join("db/seeds/holidays.rb")
puts "Seeding multipliers..."
load Rails.root.join("db/seeds/mult.rb")
puts "Seeding Gov Brackets..."
load Rails.root.join("db/seeds/gov_deductions.rb")
puts "Seeding Master Deductions..."
load Rails.root.join("db/seeds/deductions.rb")
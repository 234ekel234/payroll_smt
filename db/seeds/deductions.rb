# db/seeds.rb
Deduction.find_or_create_by!(name: 'SSS') do |d|
  d.category = 'Statutory'
  d.active = true
  d.notes = 'Social Security System Contribution'
end

Deduction.find_or_create_by!(name: 'PHIC') do |d|
  d.category = 'Statutory'
  d.active = true
  d.notes = 'PhilHealth Insurance'
end

Deduction.find_or_create_by!(name: 'HDMF') do |d|
  d.category = 'Statutory'
  d.active = true
  d.notes = 'Pag-IBIG Fund'
end
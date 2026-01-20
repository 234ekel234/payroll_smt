# db/seeds/deductions.rb
puts "Seeding Master Deduction Templates (UI Records)..."
Deduction.where(category: 'Statutory').destroy_all
Deduction.destroy_all
statutory_templates = [
  { name: 'SSS', notes: 'Social Security System' },
  { name: 'PHIC', notes: 'PhilHealth Insurance' },
  { name: 'HDMF', notes: 'Pag-IBIG Fund' }
]

statutory_templates.each do |item|
  Deduction.create!(
    name: item[:name],
    category: 'Statutory',
    active: true,
    notes: item[:notes],
    amount: 0.0,
    amount_type: 'fixed'
  )
end
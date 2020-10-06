FactoryBot.define do
  factory :customer, class: Customer do
  	association :bank
    first_name 'Juan'
    last_name 'Olaizabal'
    idn Faker::IDNumber.spanish_citizen_number
  end
end
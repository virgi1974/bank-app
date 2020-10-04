FactoryBot.define do
  factory :bank, class: Bank do
    name Faker::Bank.name
    bank_number '2100'
  end
end
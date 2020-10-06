FactoryBot.define do
  factory :account, class: Account do
  	association :customer
    balance 4000.3
    account_number Faker::Bank.account_number
  end
end
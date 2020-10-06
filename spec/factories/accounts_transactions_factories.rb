FactoryBot.define do

  factory :account_transaction, class: AccountTransaction do
  	association :account
		bank_to_account Faker::Bank.account_number
		transaction_type "EXTERNAL"
		status "PENDING"
		transefered_amount 40.3
		bank_to_code "2200"
		bank_from_code "2100"
  end
end

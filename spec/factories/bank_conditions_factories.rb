FactoryBot.define do
  factory :bank_condition, class: BankCondition do
  	association :bank

		external_bank_number "2220" 
		commission 5.0 
		max_amount 1000.0 
		min_amount 1.0 
		transaction_type "EXTERNAL"
  end
end




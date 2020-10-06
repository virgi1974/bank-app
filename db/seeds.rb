bank_database = Rails.configuration.database_configuration["development"]["database"]

# loading basic DB setup for bank A
if bank_database.include?("bank_A")
	main_bank = Bank.create(name: "A", bank_number: "2100")

	customer_1 = {bank_id: main_bank.id, first_name: "Jose", last_name: "Navarro", idn: "53241059-S"}
	customers = Customer.create([customer_1])

	account_1 = {customer_id: Customer.first.id, balance: 30000.500, account_number: "8793744742"}
	account_2 = {customer_id: Customer.first.id, balance: 5000.400, account_number:  "4353059298"}
	accounts = Account.create([account_1, account_2])

	condition_1 = {bank_id: main_bank.id, external_bank_number: main_bank.bank_number, commission: 0, max_amount: 5000, min_amount: 0, transaction_type: "INTERNAL"}
	condition_2 = {bank_id: main_bank.id, external_bank_number: "2200", commission: 5.0, max_amount: 1000, min_amount: 1, transaction_type: "EXTERNAL"}
	bank_conditions = BankCondition.create([condition_1, condition_2])

# loading basic DB setup for bank B
elsif bank_database.include?("bank_B")
	main_bank = Bank.create(name: "B", bank_number: "2200")

	customer_1 = {bank_id: main_bank.id, first_name: "Antonio", last_name: "Machado", idn: "62749272-M"}
	customer_2 = {bank_id: main_bank.id, first_name: "María", last_name: "Salgado", idn: "72909718-V"}
	customers = Customer.create([customer_1, customer_2])

	account_1 = {customer_id: Customer.first.id, balance: 25000.200, account_number: "0212354017"}
	account_2 = {customer_id: Customer.first.id, balance: 5000.300, account_number: "3076709883"}
	account_3 = {customer_id: Customer.second.id, balance: 20000.100, account_number: "6501260948"}
	account_4 = {customer_id: Customer.second.id, balance: 12500.6, account_number: "0970107485"}
	accounts = Account.create([account_1, account_2, account_3, account_4])

	condition_1 = {bank_id: main_bank.id, external_bank_number: main_bank.bank_number, commission: 0, max_amount: 5000, min_amount: 0, transaction_type: "INTERNAL"}
	condition_2 = {bank_id: main_bank.id, external_bank_number: "2100", commission: 5.0, max_amount: 1000, min_amount: 1, transaction_type: "EXTERNAL"}
	bank_conditions = BankCondition.create([condition_1, condition_2])
end


ta_bank_register_1 = {name: 'A', bank_number: '2100', host: 'http://localhost:3000'}
ta_bank_register_2 = {name: 'B', bank_number: '2200', host: 'http://localhost:3001'}
TaBankRegister.create([ta_bank_register_1, ta_bank_register_2])







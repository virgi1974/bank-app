json.total_count @transactions.size
json.transactions @transactions do |transaction|
  json.partial! 'transaction', transaction: transaction
end
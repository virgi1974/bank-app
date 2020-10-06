Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "accounts/internal_transaction", to: "accounts#internal_transaction"
      post "accounts/external_transaction", to: "accounts#external_transaction"
      post "accounts/incoming_transaction", to: "accounts#incoming_transaction"

      get "transactions/(:type)", to: "account_transactions#index"
    end
  end

  namespace :ta do
  	post "/transfer_between_banks", to: "transfers#transfer_between_banks"
  end
end
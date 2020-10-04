Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "accounts/internal_transaction", to: "accounts#internal_transaction"
    end
  end
end
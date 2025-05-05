Rails.application.routes.draw do
  root "application#index"
  get "test_error", to: "application#test_error"
end

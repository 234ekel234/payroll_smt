# config/routes.rb
Rails.application.routes.draw do
  resources :deductions
  resources :pay_multipliers
  resources :payrolls
  resources :holidays
  root "employees#index"

  resources :employees

  resources :daily_time_records do
    collection do
      post :import_file   # /daily_time_records/import_file
      post :import_google # /daily_time_records/import_google
    end
  end

  resources :holidays
  resources :payrolls do
    collection do
      post :generate
    end
  end

  # Example of other resources if needed
  # resources :payrolls
  # resources :deductions

end

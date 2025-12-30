# config/routes.rb
Rails.application.routes.draw do
  root "employees#index"

  resources :employees

  resources :daily_time_records do
    collection do
      post :import_file   # /daily_time_records/import_file
      post :import_google # /daily_time_records/import_google
    end
  end

  # Example of other resources if needed
  # resources :payrolls
  # resources :deductions

end

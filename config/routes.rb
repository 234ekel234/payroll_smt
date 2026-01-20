# config/routes.rb
Rails.application.routes.draw do
  resources :pay_multipliers
  resources :payrolls
  resources :holidays
  root "employees#index"
  resources :gov_deduction_brackets
  resources :employees
  get 'attendance_report', to: 'reports#attendance'
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
  resources :deductions do
    member do
      patch :toggle_status
    end
  end


  # Example of other resources if needed
  # resources :payrolls
  # resources :deductions

end

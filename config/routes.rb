# config/routes.rb
Rails.application.routes.draw do
  resources :shifts
  resources :pay_multipliers
  resources :holidays
  root "employees#index"
  resources :gov_deduction_brackets
  resources :employees do
    collection do
      patch :bulk_update
    end
  end
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
      get :bulk_print
      get :download_summary
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

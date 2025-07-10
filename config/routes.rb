Rails.application.routes.draw do
  namespace :admin do
    get 'dashboards/index', to: 'dashboards#index'
    resources :budget_categories, only: %i[index new create edit update destroy]

    resources :budget_cycles, only: %i[index new create edit update destroy show]

    resources :budget_cycles do
      resources :voting_phases
    end
  end
  resources :votes, only: [:create]

  resources :budget_cycles, only: [] do
    resources :votes, only: %i[new create index]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root 'admin/dashboards#index'
end

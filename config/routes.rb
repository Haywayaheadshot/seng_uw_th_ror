Rails.application.routes.draw do
  namespace :admin do
    get 'dashboards/index', to: 'dashboards#index'
    get 'dashboards/impact_report/:budget_cycle_id', to: 'dashboards#impact_report', as: :impact_report

    resources :budget_categories, only: %i[index new create edit update destroy]
    resources :budget_cycles do
      resources :voting_phases
      resources :budget_projects
    end
    resources :participants
  end

  resources :budget_cycles, only: [:index] do
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
  root 'budget_cycles#index'
end

Rails.application.routes.draw do
  root to: "application#index"
  resources :conferences, only: [:index, :show, :create] do
    resources :events, only: [:create, :index, :show]
    resources :conference_days, only: [:index, :create], as: :days
  end

  resources :events, only: [:show]

  resources :conference_days, only: [:show] do
    resources :conference_day_plan, only: [:index, :create], as: :plan
  end
end

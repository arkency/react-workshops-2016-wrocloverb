Rails.application.routes.draw do
  root to: "root#index"
  resources :conferences, only: [:index, :show, :create, :destroy] do
    resources :events, only: [:create, :index]
    resources :conference_days, only: [:index, :create], as: :days
  end

  resources :events, only: [:show, :destroy]

  resources :conference_days, only: [:show, :destroy] do
    resources :conference_day_plan, only: [:index, :create], as: :plan
  end

  resources :conference_day_plan, only: [:show, :destroy]
end

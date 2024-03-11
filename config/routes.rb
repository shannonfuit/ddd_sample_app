# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount RailsEventStore::Browser => '/res' if Rails.env.development?
  mount Sidekiq::Web => '/sidekiq'

  devise_for :contacts, controllers: {
    sessions: 'customer/contacts/sessions',
    registrations: 'customer/contacts/registrations'
  }

  devise_for :candidates, controllers: {
    sessions: 'app/candidates/sessions',
    registrations: 'app/candidates/registrations'
  }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root 'contacts/jobs#index'
  namespace :customer do
    resources :jobs, param: :uuid, only: %i[index show new create] do
      member do
        put :unpublish
        put :accept_application, to: 'jobs#accept_application'
        put :reject_application, to: 'jobs#reject_application'
      end
    end

    root 'contacts/jobs#index'
  end
end

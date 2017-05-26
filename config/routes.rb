Rails.application.routes.draw do
  get 'check' => 'application#check'
  get 'data_sync_check' => 'application#data_sync_check'

  devise_for :users, module: 'users', skip: :sessions

  devise_scope :user do
    get '/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  # Legacy sign in path
  get '/sign_in', to: redirect('/dashboard')

  devise_for :subscriptions,
    controllers: {
      confirmations: 'subscriptions',
    }

  get '/dashboard' => 'users/dashboard#index', as: 'dashboard'
  scope '/dashboard', as: :dashboard do
    resources :enquiries, only: [:show], controller: 'users/enquiries'
  end

  # Legacy dashboard index page
  get '/dashboard/enquiries', to: redirect('/dashboard')

  namespace :admin do
    devise_for :editors,
      singular: :editor,
      only: [:registrations, :sessions, :passwords, :unlocks],
      path_names: {
        sign_up: 'new',
      }

    devise_scope :editor do
      get '/editor/confirmation', to: 'confirmations#show', as: :editor_confirmation
      patch '/editor/confirmation', to: 'confirmations#update', as: :update_editor_confirmation

      delete 'editors/deactivate/:id', to: 'registrations#destroy', as: :editor_deactivate
    end

    resources :editors, only: [:index, :show, :edit, :update]

    authenticated :editor do
      resources :enquiries, only: [:index, :show]
      resources :enquiry_responses
    end

    resources :opportunities, only: [:index, :show, :new, :create, :edit, :update] do
      authenticated :editor do
        collection do
          resources :downloads, only: [:new, :create], controller: 'opportunity_downloads', as: :opportunity_downloads
        end

        resources :comments, only: [:create], controller: 'opportunity_comments'
      end

      resource :status, only: [:update, :destroy], controller: 'opportunity_status'
    end

    require 'constraints/flipper_admin_constraint'
    constraints FlipperAdminConstraint.new do
      flipper_block = -> { ExportOpportunities.flipper }
      mount Flipper::UI.app(flipper_block) => '/feature-flags'
    end

    resources :stats do
    end


    root to: redirect('/admin/opportunities')
  end

  get '/enquiries/:slug' => 'enquiries#new', as: :new_enquiry
  post '/enquiries/:slug' => 'enquiries#create', as: :enquiries

  resources :company_details, only: [:index]

  resources :opportunities, only: [:index, :show]

  # site's root page
  root 'opportunities#index'

  resources :subscriptions, only: [:create, :show, :destroy, :update]
  resources :pending_subscriptions, only: [:create]
  get '/pending_subscriptions/:id' => 'pending_subscriptions#update', as: :update_pending_subscription

  # for unsubscribing from emails, which can't normally handle delete method etc.
  get '/subscriptions/unsubscribe/:id' => 'subscriptions#destroy', as: :unsubscribe
  patch '/subscriptions/explain/:id' => 'subscriptions#update', as: :explain_unsubscribe

  resources :bulk_subscriptions, only: [:index, :create]
  # for old emails, which may still have the v1 prefix
  # TODO: delete this when old subscription emails are sufficiently old
  get '/v1/subscriptions/unsubscribe/:id' => 'subscriptions#destroy'
  patch '/v1/subscriptions/explain/:id' => 'subscriptions#update'

  # The constraints on the following routes will match individual values
  # (e.g. "france", "brazil", "the-usa", "100k", "aerospace") but not the
  # comma-separated values Rails spits out to represent multiply-valued fields.
  # This means we'll get /country/brazil but not /country/brazil,france
  # and we won't get nasty stuff like /country/the-usa?sector=aerospace
  # if there's more than one value, it should fall back to using the
  # standard /opportunity route with the filters in the params. -TM

  get '/country/:countries', to: 'opportunities#index', as: :opportunities_by_country, constraints: { countries: /[\w\-]+/ }
  get '/industry/:sectors', to: 'opportunities#index', as: :opportunities_by_sector, constraints: { sectors: /[\w\-]+/ }
  get '/sector/:types', to: 'opportunities#index', as: :opportunities_by_type, constraints: { types: /[\w\-]+/ }
  get '/value/:values', to: 'opportunities#index', as: :opportunities_by_value, constraints: { values: /[\w\-]+/ }

  # Atom feed
  get '/feed', action: :index, controller: 'opportunities', format: 'atom'

  scope module: :v1, path: 'v1', constraints: { format: /json/ } do
    resources :opportunities, only: [:show] do
      collection do
        resource :count, controller: 'opportunities_count', only: [:show]
      end
    end
  end

  # Legacy admin sign in paths
  get '/users/sign_in', to: redirect('/admin/editors/sign_in'), as: nil
  get '/users/sign_out', to: redirect('/admin/editors/sign_out'), as: nil
  get '/user/confirmation', to: redirect { |_params, request| "/admin/editor/confirmation?#{request.params.to_query}" }

  # Enquiry feedback
  get '/feedback', to: 'enquiry_feedback#new', as: :enquiry_feedback
  get '/feedback/opt_out', to: 'feedback_opt_outs#create', via: :get, as: :feedback_opt_out
  patch '/feedback.:id', to: 'enquiry_feedback#patch'

  # Error pages
  match '/500' => 'errors#internal_server_error', via: :all
  match '/404' => 'errors#not_found', via: :all

  # Mailer previews. This need to be declared explicitly or they get snapped up
  # by the wildcard rule below before Rails has a chance to route them
  if Rails.env.development?
    get '/rails/mailers' => 'rails/mailers#index'
    get '/rails/mailers/*path' => 'rails/mailers#preview'
  end

  get '/api/profile_dashboard', action: :index, controller: 'api/profile_dashboard', format: 'json', via: [:get]

  match '*path', to: 'errors#not_found', via: [:get, :post, :patch, :put, :delete]

  match '(*path)',
    to: ->(_env) { [405, { 'Content-Type' => 'text/plain' }, ["\n"]] },
    via: [:options]
end

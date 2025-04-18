# coding: utf-8
Rails.application.routes.draw do
  scope 'export-opportunities' do
    mount Sidekiq::Web => '/sidekiq'

    # site's root page
    root to: 'opportunities#index'

    get 'check' => 'application#check'
    get 'data_sync_check' => 'data_sync#check'
    get 'api_check' => 'application#api_check'
    get 'robots.txt' => 'robots_txts#show'
    get '/pingdom/ping' => 'application#ping'

    devise_for :users, module: 'users', skip: :sessions

    devise_scope :user do
      get '/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
    end

    # Legacy sign in path
    get '/sign_in', to: redirect('export-opportunities/dashboard')

    devise_for :subscriptions,
               controllers: {
                confirmations: 'subscriptions',
               }

    get '/dashboard' => 'users/dashboard#index', as: 'dashboard'
    # get '/export-opportunities/dashboard/downloads' => 'users/downloads'
    scope '/dashboard', as: :dashboard do
      resources :enquiries, only: [:show], controller: 'users/enquiries'
      resources :downloads, only: [:show], controller: 'users/downloads'
    end

    # Legacy dashboard index page
    get '/dashboard/enquiries', to: redirect('export-opportunities/dashboard')

    resources :opportunities, only: [:show] do
      root action: 'results', as: ''
    end

    namespace :admin do
      get 'help', to: 'help#index'
      get 'help/:article_id', to: 'help#show'
      get 'help/:article_id/print', to: 'help#article_print', as: 'help_article_print'
      get 'help/:article_id/:section_id', to: 'help#article', as: 'help_article'

      devise_for :editors,
                 singular: :editor,
                 only: %i[registrations sessions passwords unlocks],
                 path_names: {
                   sign_up: 'new',
                 }

      devise_scope :editor do
        get '/editor/confirmation', to: 'confirmations#show', as: :editor_confirmation
        patch '/editor/confirmation', to: 'confirmations#update', as: :update_editor_confirmation

        put 'editors/reactivate/:id', to: 'registrations#reactivate', as: :editor_reactivate
        delete 'editors/deactivate/:id', to: 'registrations#destroy', as: :editor_deactivate
      end

      resources :editors, only: %i[index show edit update]

      resources :enquiries

      authenticated :editor do
        resources :enquiry_responses do
          get 'email_send', on: :collection
        end
      end

      resources :opportunities, only: %i[index show new create edit update] do
        authenticated :editor do
          collection do
            resources :downloads, only: %i[new create], controller: 'opportunity_downloads', as: :opportunity_downloads
          end

          resources :comments, only: %i[create], controller: 'opportunity_comments'
        end

        resource :status, only: %i[update destroy], controller: 'opportunity_status'
      end

      require 'constraints/flipper_admin_constraint'
      constraints FlipperAdminConstraint.new do
        flipper_block = -> { ExportOpportunities.flipper }
        mount Flipper::UI.app(flipper_block) => '/feature-flags'
      end

      resources :stats do
      end

      resources :reports do
        get 'impact_email' => 'reports_controller#impact_email'
      end

      get 'updates' => 'updates#index'

      root to: redirect('export-opportunities/admin/opportunities')
    end

    get '/enquiries/:slug' => 'enquiries#new', as: :new_enquiry
    post '/enquiries/:slug' => 'enquiries#create', as: :enquiries
    get '/enquiries/:slug/feedback' => 'customer_satisfaction_feedback#cancel', as: :customer_satisfaction_cancel
    post '/enquiries/:slug/feedback' => 'customer_satisfaction_feedback#create', as: :customer_satisfaction_rating
    patch '/enquiries/:slug/feedback' => 'customer_satisfaction_feedback#update', as: :customer_satisfaction_feedback

    resources :company_details, only: [:index]

    resources :subscriptions, only: %i[create show destroy update]
    resources :pending_subscriptions, only: [:create]
    get '/pending_subscriptions/:id' => 'pending_subscriptions#update', as: :update_pending_subscription

    # for unsubscribing from emails, which can't normally handle delete method etc.
    get '/subscriptions/unsubscribe/:id' => 'subscriptions#destroy', as: :unsubscribe
    patch '/subscriptions/explain/:id' => 'subscriptions#update', as: :explain_unsubscribe

    resources :bulk_subscriptions, only: %i[index create]
    # for old emails, which may still have the v1 prefix
    # TODO: delete this when old subscription emails are sufficiently old
    get '/v1/subscriptions/unsubscribe/:id' => 'subscriptions#destroy'
    patch '/v1/subscriptions/explain/:id' => 'subscriptions#update'

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
    get '/users/sign_in', to: redirect('export-opportunities/admin/editors/sign_in'), as: nil
    # get '/users/sign_out', to: redirect('export-opportunities/admin/editors/sign_out'), as: nil
    get '/user/confirmation', to: redirect { |_params, request| "export-opportunities/admin/editor/confirmation?#{request.params.to_query}" }

    # Enquiry feedback
    get '/feedback', to: 'enquiry_feedback#new', as: :enquiry_feedback
    get '/feedback/opt_out', to: 'feedback_opt_outs#create', via: :get, as: :feedback_opt_out
    patch '/feedback/:id', to: 'enquiry_feedback#patch', as: :patch_enquiry_feedback

    # Error pages
    match '/500' => 'errors#internal_server_error', via: :all
    match '/404' => 'errors#not_found', via: :all

    # Mailer previews. This need to be declared explicitly or they get snapped up
    # by the wildcard rule below before Rails has a chance to route them
    # if Rails.env.development?
    get '/rails/mailers' => 'rails/mailers#index'
    get '/rails/mailers/*path' => 'rails/mailers#preview'
    # end


    get '/email_notifications/unsubscribe_all/:unsubscription_token', to: 'email_notifications#destroy', as: :delete_email_notifications
    patch '/email_notifications/unsubscribe_all/:unsubscription_token', to: 'email_notifications#update', as: :update_email_notification

    get '/api/cn/cpv', action: :search,
                       controller: 'api/cpv_lookup',
                       format: :json,
                       via: [:get]
    get '/api/profile_dashboard', action: :index, controller: 'api/profile_dashboard', format: 'json', via: [:get]
    get '/api/opportunities', action: :opportunities, controller: 'api/profile_dashboard', format: 'json', via: [:get]
    get '/api/activity_stream/', action: :index,
      controller: 'api/activity_stream', format: 'json', via: [:get] # Old route
    get '/api/activity_stream/enquiries', action: :enquiries,
      controller: 'api/activity_stream', format: 'json', via: [:get], as: :activity_stream_enquiries
    get '/api/activity_stream/opportunities', action: :opportunities,
      controller: 'api/activity_stream', format: 'json', via: [:get], as: :activity_stream_opportunities
    get '/api/activity_stream/csat_feedback', action: :csat_feedback,
      controller: 'api/activity_stream', format: 'json', via: [:get], as: :activity_stream_csat_feedback

    post '/api/document/', action: :create, controller: 'api/document'

    match '*path', to: 'errors#not_found', via: %i[get post patch put delete]

    match '(*path)',
          to: ->(_env) { [405, { 'Content-Type' => 'text/plain' }, ["\n"]] },
          via: [:options]
  end

  # site's root page
  get '', to: 'opportunities#index'

  get 'check' => 'application#check'
  get 'data_sync_check' => 'application#data_sync_check'
  get 'api_check' => 'application#api_check'
  get 'robots.txt' => 'robots_txts#show'

  # devise_for :users, module: 'users', skip: :sessions

  devise_scope :user do
    get '/sign_out', to: 'users/sessions#destroy'
  end

  # Legacy sign in path
  get '/sign_in', to: redirect('export-opportunities/dashboard')

  # devise_for :subscriptions,
  #            controllers: {
  #             confirmations: 'subscriptions',
  #            }

  get '/dashboard' => 'users/dashboard#index'
  # get '/export-opportunities/dashboard/downloads' => 'users/downloads'
  scope '/dashboard', as: :dashboard do
    resources :enquiries, only: [:show], controller: 'users/enquiries'
    resources :downloads, only: [:show], controller: 'users/downloads'
  end

  # Legacy dashboard index page
  get '/dashboard/enquiries', to: redirect('export-opportunities/dashboard')

  resources :opportunities, only: [:show] do
    root action: 'results'
  end

  namespace :admin do
    get 'help', to: 'help#index'
    get 'help/:article_id', to: 'help#show'
    get 'help/:article_id/print', to: 'help#article_print'
    get 'help/:article_id/:section_id', to: 'help#article'

    # devise_for :editors,
    #            singular: :editor,
    #            only: %i[registrations sessions passwords unlocks],
    #            path_names: {
    #              sign_up: 'new',
    #            }

    devise_scope :editor do
      get '/editor/confirmation', to: 'confirmations#show'
      patch '/editor/confirmation', to: 'confirmations#update'

      put 'editors/reactivate/:id', to: 'registrations#reactivate'
      delete 'editors/deactivate/:id', to: 'registrations#destroy'
    end

    resources :editors, only: %i[index show edit update]

    resources :enquiries

    authenticated :editor do
      resources :enquiry_responses do
        get 'email_send', on: :collection
      end
    end

    resources :opportunities, only: %i[index show new create edit update] do
      authenticated :editor do
        collection do
          resources :downloads, only: %i[new create], controller: 'opportunity_downloads'
        end

        resources :comments, only: %i[create], controller: 'opportunity_comments'
      end

      resource :status, only: %i[update destroy], controller: 'opportunity_status'
    end

    require 'constraints/flipper_admin_constraint'
    constraints FlipperAdminConstraint.new do
      flipper_block = -> { ExportOpportunities.flipper }
      mount Flipper::UI.app(flipper_block) => '/feature-flags'
    end

    resources :stats do
    end

    resources :reports do
      get 'impact_email' => 'reports_controller#impact_email'
    end

    get 'updates' => 'updates#index'

    get '', to: redirect('export-opportunities/admin/opportunities')
  end

  get '/enquiries/:slug' => 'enquiries#new'
  post '/enquiries/:slug' => 'enquiries#create'

  resources :company_details, only: [:index]

  resources :subscriptions, only: %i[create show destroy update]
  resources :pending_subscriptions, only: [:create]
  get '/pending_subscriptions/:id' => 'pending_subscriptions#update'

  # for unsubscribing from emails, which can't normally handle delete method etc.
  get '/subscriptions/unsubscribe/:id' => 'subscriptions#destroy'
  patch '/subscriptions/explain/:id' => 'subscriptions#update'

  resources :bulk_subscriptions, only: %i[index create]
  # for old emails, which may still have the v1 prefix
  # TODO: delete this when old subscription emails are sufficiently old
  get '/v1/subscriptions/unsubscribe/:id' => 'subscriptions#destroy'
  patch '/v1/subscriptions/explain/:id' => 'subscriptions#update'

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
  get '/users/sign_in', to: redirect('export-opportunities/admin/editors/sign_in')
  # get '/users/sign_out', to: redirect('export-opportunities/admin/editors/sign_out')
  get '/user/confirmation', to: redirect { |_params, request| "export-opportunities/admin/editor/confirmation?#{request.params.to_query}" }

  # Enquiry feedback
  get '/feedback', to: 'enquiry_feedback#new'
  get '/feedback/opt_out', to: 'feedback_opt_outs#create', via: :get
  patch '/feedback/:id', to: 'enquiry_feedback#patch'

  # Error pages
  match '/500' => 'errors#internal_server_error', via: :all
  match '/404' => 'errors#not_found', via: :all

  # Mailer previews. This need to be declared explicitly or they get snapped up
  # by the wildcard rule below before Rails has a chance to route them
  # if Rails.env.development?
  get '/rails/mailers' => 'rails/mailers#index'
  get '/rails/mailers/*path' => 'rails/mailers#preview'
  # end

  get '/email_notifications/unsubscribe_all/:unsubscription_token', to: 'email_notifications#destroy'
  patch '/email_notifications/unsubscribe_all/:unsubscription_token', to: 'email_notifications#update'

  get '/api/cn/cpv', action: :search,
                     controller: 'api/cpv_lookup',
                     format: :json,
                     via: [:get]
  get '/api/profile_dashboard', action: :index, controller: 'api/profile_dashboard', format: 'json', via: [:get]
  get '/api/activity_stream/', action: :index,
    controller: 'api/activity_stream', format: 'json', via: [:get] # Old route
  get '/api/activity_stream/enquiries', action: :enquiries,
    controller: 'api/activity_stream', format: 'json', via: [:get]
  get '/api/activity_stream/opportunities', action: :opportunities,
    controller: 'api/activity_stream', format: 'json', via: [:get]
  post '/api/document/', action: :create, controller: 'api/document'

  match '*path', to: 'errors#not_found', via: %i[get post patch put delete]

  match '(*path)',
        to: ->(_env) { [405, { 'Content-Type' => 'text/plain' }, ["\n"]] },
        via: [:options]
end

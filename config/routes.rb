require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :admins do
    resources :sessions, only: %i(new create) do
      get :logout, on: :collection
      collection do
        #post :create
      end
    end

    resources :users
  end

  scope path: 'api/v4' do
    devise_for :users, path: 'auth',
                       skip: [:sessions, :passwords, :registrations]
                       #path_names: {sign_in: 'token_by_login'},
                       #controllers: {sessions:  "users/sessions"}
    scope path: 'auth' do
      as :user do
        post 'token_by_login'    => 'users/sessions#create'
        post 'token_by_mobile'   => 'users/sessions#create_by_mobile'
        post 'send_verify_code'  => 'users/sessions#send_verify_code'
        get  'check_verify_code' => 'users/sessions#check_verify_code'
      end
    end

    scope path: 'password' do
      as :user do
        put 'update'   => 'users/passwords#change_password'
        post 'create'  => 'users/passwords#send_verify_code'
      end
    end

    scope path: 'registration' do
      as :user do
        post 'create'  => 'users/registrations#create'
        put 'update'   => 'users/registrations#update_token'
      end
    end
    scope path: 'attachments' do
      post "callback/:provider" => 'attachments#callback'
      post "public_callback/:provider" => 'attachments#public_callback'
      get 'public_upload_token' => 'attachments#public_upload_token'
    end
    scope path: 'messages' do
      get ':id/upload_token' => 'attachments#upload_token'
    end
  end

  scope path: 'api/v5' do
    devise_for :users, path: 'auth',
                       skip: [:sessions, :passwords, :registrations]
                       #path_names: {sign_in: 'token_by_login'},
                       #controllers: {sessions:  "users/sessions"}
    scope path: 'auth' do
      as :user do
        post 'token_by_login'   => 'users/sessions#create'
        post 'token_by_mobile'   => 'users/sessions#create_by_mobile'
        post 'send_verify_code'  => 'users/sessions#send_verify_code'
      end
    end
  end
  #scope path: 'api/v4/auth' do
  #  devise_scope :user do
  #    post 'token_by_mobile'   => 'users/sessions#create_by_mobile'
  #    post 'send_verify_code'  => 'users/sessions#send_verify_code'
  #  end
  #end

  # scope path: 'api/v5/auth' do
  #   devise_scope :user do
  #     post 'token_by_login'    => 'users/sessions#create'
  #     post 'token_by_mobile'   => 'users/sessions#create_by_mobile'
  #     post 'send_verify_code'  => 'users/sessions#send_verify_code'
  #   end
  # end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  namespace :api do
    namespace :v4 do
      post 'friend_requests', to: 'sent_friend_requests#create'

      scope path: 'friend_requests' do
        concern :friend_requests_with_state do
          get :index, path: ':state', constraints: { state: /pending|accepted|rejected|blocked/ }, on: :collection
        end

        resources :sent_friend_requests, only: %i(index create destroy), path: 'sent', concerns: :friend_requests_with_state
        resources :received_friend_requests, only: %i(index destroy), path: 'received', concerns: :friend_requests_with_state do
          member do
            patch :accept
            patch :reject
            patch :block
          end
        end
      end

      resources :friendships, only: %i(index update show) do
        patch :move_to_top, on: :member
        collection do
          get :recent
          get :search
          get :by_friend, path: '/with/:friend_id'
        end
      end

      resources :groups, only: %i(index create update destroy show) do
        post 'add_friendship', to: 'friendships_groups#create'
        delete 'remove_friendship/:friendship_id', to: 'friendships_groups#destroy'
      end

      resources :messages, only: %i(create show) do
        get :unread, on: :collection
        member do
          patch :mark_as_read
          patch :deliver
          post :notify_screenshot
        end
      end

      resources :reports, only: %i(create)
      resources :unfriend_requests, only: %i(create)
      resources :contacts, only: [] do
        post :upload, on: :collection
      end

      resource :user, controller: :user, only: %i(show update) do
        collection do
          get :may_know_friends
          patch :update_mobile
        end
      end

      resources :users, only: [] do
        collection do
          get :search
          get :username_validate
          get :mobile_validate
        end
      end
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root to: "home#index"

  # don't raise ActionController::RoutingError
  match '*path', via: :all, to: 'api#error_404'
end

Rails.application.routes.draw do
  scope path: 'api/v4' do
    devise_for :users, path: 'auth',
                       path_names: {sign_in: 'token_by_login'},
                       controllers: {sessions: "users/sessions"}
    scope 'auth' do
      post 'token_by_mobile' => 'users/sessions#create'
    end
  end
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
      resources :friend_requests, only: %i(create show destroy) do
        member do
          patch :accept
          patch :reject
          patch :block
        end
      end
    end
  end

  root to: "home#index"

  #scope path: 'api/v4' do
  #  resources :auth do
  #    collection do
  #      #post 'token_by_login'  => "auth#create"
  #      post 'token_by_mobile' => "users/sessions#create"
  #    end
  #  end
  #end

end

Poploda::Application.routes.draw do
  get "etisalats/index"

  get "airtels/index"

  get "mtns/index"

  get "glos/index"

  get "welcome/index"

  get "orders/index"
  get "/statistics", to: "welcome#statistics", as: :statistics

  resources :credits do
    collection { post :import}
  end
  resources :credit_imports



  get "notification/notify"

  get "/welcome", to: "welcome#index"
  resources :bulk_credits


  devise_for :users, :skip => [:sessions]  do
    get '/account/sign_in' => 'sessions#new', :as => :new_user_session
    post '/account/sign_in' => 'sessions#create', :as => :user_session
    delete '/account/sign_out' => 'sessions#destroy', :as => :destroy_user_session
  end

  resources :orders
  resources :users do
    resources :orders
  end

  resources :etisalats


  resources :airtels


  resources :glos


  resources :mtns

  match 'notify' => 'notification#notify', as: :notify
  match 'single_notify' => 'notification#single_notify', as: :single_notify
  match 'thank_you' => 'welcome#thank_you', as: :thank_you
  match 'failure' => 'welcome#failure', as: :failure
  match 'orders' => "welcome#order", as: :orders

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  match 'purchase/:name' => "credits#start_order", as: :purchase
  match 'mobile_purchase/:name' => "credits#mobile_purchase", as: :mobile_purchase
  match 'messages' => "welcome#messages", as: :messages
  match 'checkout/:id' => "orders#load_credit", as: :checkout

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  namespace :api do
    namespace :v1 do
      resources :tokens,:only => [:create]
      controller :tokens do
        get :messages
        get :users
        get :credits
        post :mobile_purchase
        post :sign_out
        post :create_order
        post :charge_order
        post :cancel_order
      end
    end
  end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

require 'sidekiq/web'
Poploda::Application.routes.draw do
  get "etisalats/index"

  get "airtels/index"

  get "mtns/index"

  get "glos/index"

  get "welcome/index"

  get "orders/index"
  get "/statistics", to: "welcome#statistics", as: :statistics
  get "/airtime_statistics",to: "welcome#airtime_statistics", as: :airtime_statistics
  get "/user_statistics",to: "welcome#user_statistics", as: :user_statistics
  get '/interswitch_transactions' => 'orders#interswitch_transactions', :as => :interswitch_transactions
  get '/wallet_transactions' => 'orders#wallet_transactions', :as => :wallet_transactions
  post '/airtime_search' => 'airtimes#search', as: :airtime_search
  post '/user_search' => 'users#search', as: :user_search

  resources :airtimes do
    collection { post :import}
  end
  resources :credit_imports
  match 'search' => "orders#search", as: :search


  get "notification/notify"

  get "/welcome", to: "welcome#index"
  resources :bulk_credits
  resources :messages

  devise_for :users, :skip => [:sessions]  do
    get '/account/sign_in' => 'sessions#new', :as => :new_user_session
    post '/account/sign_in' => 'sessions#create', :as => :user_session
    match "/account/sign_out"  => 'sessions#destroy', :as => :destroy_user_session
  end

  resources :orders do
    member do
      get :check_order_status
    end
  end
  resources :users do
    resources :orders do
      post :purchase_airtime
    end
    resource :wallet,:only=>[]do
      post :deposit
      get :load_money
      get :account
      get :order_confirmation
      post :pay
    end
    member do
      get :profile
      get :credit_wallet
      post :amount_to_credit
    end
    resources :messages  do
        get 'single_mail', on: :collection
        post 'send_single_mail', on: :collection
    end
  end

  resources :etisalats


  resources :airtels


  resources :glos


  resources :mtns

  post '/notify' => 'interswitch_notification#interswitch_notify', as: :interswitch_notify
  get '/notify' => 'interswitch_notification#show_order_status', as: :show_order_status
  post '/confirm'  => 'interswitch_notification#confirm', as: :confirm
  post '/web_pay' => 'interswitch_notification#web_pay', as: :web_pay
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

  match 'purchase/:name' => "airtimes#start_order", as: :purchase
  match 'mobile_purchase/:name' => "airtimes#mobile_purchase", as: :mobile_purchase
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

  resources :platforms do
    member do
      get :download
    end
    resource :releases
  end

  resources :news_letters do
    member do
      post 'send_now'
    end
  end

  namespace :api do
    namespace :v1 do
      devise_for :users
      resources :tokens,:only => [:create]
      controller :tokens do
        get :messages
        get :users
        get :airtimes
        post :mobile_purchase
        post :sign_out
        post :create_airtime_order
        post :charge_order
        post :cancel_order
        post :create_money_order
        post :bind
        get  :web_pay_mobile
        post :wallet_pay
        get  :interswitch_notify
        post :interswitch_notify
        get :test_push
        post :test_bind
        get :web_pay_data
        get :test_web_pay_mobile
        get :one_step_pay
        get :test_one_step_pay
        get :test_notification
      end
    end
  end

  match "/download/:os_name" =>"platforms#download", :as=>:download_release
  get 'api/v1/interswitch_notify' => 'tokens#interswitch_notify', as: :mobile_notify
  get '/mail'=>'welcome#order_mail_test'
  mount Sidekiq::Web, at: "/sidekiq"
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

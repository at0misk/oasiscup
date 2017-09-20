Rails.application.routes.draw do
  match '/payments/payment', :to => 'payments#payment', :as => 'paymentspayment', :via => [:get]
  # match '/payments/relay_response', :to => 'payments#relay_response', :as => 'payments_relay_response', :via => [:post]
  post '/payments/relay_response' => 'payments#relay_response'
  match '/payments/receipt', :to => 'payments#receipt', :as => 'payments_receipt', :via => [:get]
  get '/charge_relay' => 'charges#relay'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'users#root' 
  get 'users/new' => 'users#new'
  post 'users/create' => 'users#create'
  get 'hotels/new' => 'hotels#new'
  post 'hotels/create' => 'hotels#create'
  get 'hotels/:id' => 'hotels#view'
  get 'hotels' => 'hotels#all'
  post 'rooms/create' => 'rooms#create'
  get 'rooms/paginate' => 'rooms#paginate'
  get 'rooms/:id' => 'rooms#view'
  get 'rooms' => 'rooms#all'
  post 'book_rooms/create/:id' => 'books#create'
  post 'book_rooms/cancel/:id' => 'books#cancel'
  get 'booked' => 'books#booked'
  get 'logout' => 'sessions#logout'
  get 'login' => 'sessions#login'
  post 'sessions/new' => 'sessions#new'
  get '/users/update/:id' => 'users#edit'
  patch '/users' => 'users#update'
  post 'cart/create/:id' => 'carts#create'
  get 'cart' => 'carts#view'
  post 'cart/cancel/:id' => 'carts#cancel'
  post 'cart/checkout' => 'carts#checkout'
  get '/payment' => 'sessions#payment'
  post '/registerpay' => 'sessions#registerpay'
  get 'transactions/new' => 'transactions#new'
  post 'transactions' => 'transactions#create'
  post 'rooms/search/:id' => 'hotels#search'
  get 'roomByPrice/:id' => 'rooms#search'
  get 'guests/new' => 'guests#new'
  post 'guests/create' => 'guests#create'
  get 'guests/show' => 'guests#show'
  post 'guests/delete/:id' => 'guests#delete'
  patch 'guests/:id' => 'guests#update'
  post 'count' => 'rooms#count'
  post 'rooms/searchAll' => 'rooms#searchAll'
  patch 'users/teams' => 'users#teamupdate'
  resources :charges
  get 'rooms/generate/:id' => 'rooms#generate'
  get 'hotels/edit/:id' => 'hotels#edit'
  patch 'hotels/update/:id' => 'hotels#update'
  get 'contact' => 'sessions#contact'
  get 'booked/teams' => 'books#teams'
  get 'guests/user' => 'guests#user'
  get 'info' => 'sessions#info'
  get 'conf' => 'sessions#confirmation'
  get 'forgot_password' => 'sessions#forgot'
  post 'recover' => 'sessions#recover'
  get '/admins/dash' => 'admins#dash'
  post '/admins/searchUsers' => 'admins#searchUsersSearch'
  get '/admins/searchUsers' => 'admins#searchUsers'
  post '/admins/searchTransactions' => 'admins#searchTransactionsSearch'
  get '/admins/searchTransactions' => 'admins#searchTransactions'
  get '/transactions' => 'users#transactions'
  get '/authorize' => 'charges#authorize'
  post '/cart/paid_full' => 'carts#paid_full'
  post '/cart/first_night' => 'carts#first_night'
  post 'cart/paid_balance' => 'carts#paid_balance'
  post '/admins/searchTeamName' => 'admins#searchTeamName'
  post '/admins/searchTeamConf' => 'admins#searchTeamConf'
  get '/admins/searchTeamsNameView' => 'admins#searchTeamsNameView'
  get '/admins/searchTeamsConfView' => 'admins#searchTeamsConfView'
  get '/admins/endOfDay' => 'admins#endOfDay'
  get '/admins/mailEndOfDay' => 'admins#mailEndOfDay'
  get '/admins/yesterday' => 'admins#yesterday'
  get '/admins/monday' => 'admins#monday'
  get '/admins/one_week_warning' => 'admins#one_week_warning'
  get '/admins/allUsers' => 'admins#allUsers'
  get '/sessions/terms_and_conditions' => 'sessions#terms_and_conditions'
  post '/tc' => 'sessions#agreement'
  get '/admins/Balance' => 'admins#balance'
  get 'admins/noDown' => 'admins#no_down_payment'
  get '/admins/mail_user_report/:id' => 'admins#mail_user_report'
  get '/admins/hotel_mailed/:id' => 'admins#hotel_mailed'
  get '/admins/hotel_not_mailed/:id' => 'admins#hotel_not_mailed'
  get '/admins/ten_days' => 'admins#ten_days'
  # get '/up_price' => 'rooms#up_price'
end
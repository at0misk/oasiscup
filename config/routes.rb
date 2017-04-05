Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'users#root' 
  get 'users/new' => 'users#new'
  post 'users/create' => 'users#create'
  get 'hotels/new' => 'hotels#new'
  post 'hotels/create' => 'hotels#create'
  get 'hotels/:id' => 'hotels#view'
  get 'hotels' => 'hotels#all'
  post 'rooms/create' => 'rooms#create'
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
end
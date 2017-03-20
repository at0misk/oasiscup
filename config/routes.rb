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
end

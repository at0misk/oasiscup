class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def authenticate_user!
  	if session[:user_id]
  	else
  		redirect_to '/users/new'
  	end
  end
end

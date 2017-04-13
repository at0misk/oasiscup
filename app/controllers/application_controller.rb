class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def authenticate_user!
  	if session[:user_id]
  	else
  		redirect_to '/'
  	end
  end
  def authenticate_admin!
  	if session[:user_id]
  		@user = User.find(session[:user_id])
  		if @user.permod
  		else
  			redirect_to '/'
  		end
  	else
  		redirect_to '/'
  	end
  end
end

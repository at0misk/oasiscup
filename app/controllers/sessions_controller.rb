class SessionsController < ApplicationController
	def login
	end
	def logout
		session[:user_id] = nil
		redirect_to '/login'
	end
	def new
  	@user = User.find_by(email: params['email'])
	  	if @user && @user.authenticate(params[:password])
	  		session[:user_id] = @user.id
  			redirect_to '/'
	  	else
	  		flash[:errors] = ['Invalid email / password combination']
	  		redirect_to :back
	  	end
	end
end

class SessionsController < ApplicationController
	def login
		if session[:user_id]
			redirect_to '/'
		end
	end
	def logout
		session[:user_id] = nil
		redirect_to '/login'
	end
	def new
  	@user = User.find_by(email: params['email'])
	  	if @user && @user.authenticate(params[:password])
	  		session[:user_id] = @user.id
	  		if @user.fee_status == true
	  			session[:payed] = true
	  			redirect_to '/'
	  		else
  			redirect_to '/payment'
  			end
	  	else
	  		flash[:errors] = ['Invalid email / password combination']
	  		redirect_to :back
	  	end
	end
	def payment
		@user = User.find(session[:user_id])
    	gon.client_token = generate_client_token
    	@token = gon.client_token
	end
	def registerpay
		@user = User.find(session[:user_id])
		@user.update_attribute(:fee_status, true)
		session[:payed] = true
		redirect_to '/'
	end
	private
	def generate_client_token
		Braintree::ClientToken.generate
	end
end

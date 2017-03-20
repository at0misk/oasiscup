class UsersController < ApplicationController
	def new
	end
	def create
		@user = User.new(user_params)
		if @user.save
			@user.update(:fee_status => false)
			session[:user_id] = @user.id
			redirect_to '/'
		else
			flash[:errors] = @user.errors.full_messages
			redirect_to :back
		end
	end
	def root
		@user = User.find(session[:user_id])
	end
  	def user_params
  	params.require(:user).permit(:first, :last, :email, :team, :fee_status, :password) 
  	end
  	def edit
  		@user = User.find(session[:user_id])
  	end
   	def update
  		@user = User.find(session[:user_id])
	    @user.update(user_params)
	    redirect_to :back
  	end
end

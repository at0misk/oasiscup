class SessionsController < ApplicationController
	before_action :authenticate_user!, :except => [:login, :logout, :new, :forgot, :recover, :terms_and_conditions, :agreement]
	def login
		if session[:user_id]
			redirect_to '/hotels'
		end
	end
	def logout
		session[:user_id] = nil
		redirect_to '/'
	end
	def new
  	@user = User.find_by(email: params['email'])
	  	if @user && @user.authenticate(params[:password])
	  		if @user.agree
	  		session[:user_id] = @user.id
	  		# if @user.permod
	  		# 	redirect_to '/admins/dash'
	  		# else
	  		# if @user.fee_status == true
	  		# 	session[:payed] = true
			redirect_to '/hotels'
	  		# else
  			# redirect_to '/payment'
  			# end
  			# end
  			else
  			session[:agree] = @user.id
  			redirect_to '/sessions/terms_and_conditions'
  			end
	  	else
	  		flash[:errors] = ['Email / Password not valid']
	  		session[:modalFail] = true
	  		redirect_to :back
	  	end
	end
	def payment
		@user = User.find(session[:user_id])
    	gon.client_token = generate_client_token
    	@token = generate_client_token
	end
	def registerpay
		@user = User.find(session[:user_id])
		@user.update_attribute(:fee_status, true)
		# session[:payed] = true
		redirect_to '/'
	end
	def contact
	end
	def info
		@user = User.find(session[:user_id])
		@team = @user.team
	end
	def confirmation
		@user = User.find(session[:user_id])
		@team = @user.team
		@type = Transaction.where(user_id: @user.id).last
		if @team.mail_confirmation
			flash[:mailSent] = "Confirmation Sent"
			UserMailer.confirmation_email(@user, @type).deliver_now
		else
		end
			redirect_to :back
	end
	def forgot
	end
	def recover
		@user = User.find_by(email: params['email'])
		if !@user
			flash[:no_user] = "Email not found"
		else
			random_password = Array.new(10).map { (65 + rand(58)).chr }.join
			@user.password = random_password
			@user.save!
			UserMailer.create_and_deliver_password_change(@user, random_password).deliver_now
			flash[:email_success] = "Email sent"
		end
		redirect_to :back
	end
	def terms_and_conditions
		@user = User.find(session[:agree])
		@team = @user.team
	end
	def agreement
		if params['agree']
			session[:user_id] = session[:agree]
			@user = User.find(session[:user_id])
			@user.update_attribute(:agree, true)
			@user.save
			UserMailer.welcome_email(@user).deliver_now
			redirect_to '/hotels'
		else
			session[:user_id] = nil
			redirect_to '/'
		end
	end
	# def new
	#   gon.client_token = generate_client_token
	# end
	private
	def generate_client_token
		Braintree::ClientToken.generate
	end
end

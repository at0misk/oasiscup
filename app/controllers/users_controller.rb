class UsersController < ApplicationController
	before_action :authenticate_user!, :except => [:new, :create, :root]
	def new
	end
	def create
		puts params['team']['conf_num']
		puts params['team']['exempt']
		@t = Team.find_by(conf_num: params['team']['conf_num'])
		if @t
			@user = User.new(user_params)
			@user.team_id = @t.id
			if @user.save
				@guest = Guest.new(first: @user.first, last: @user.last, guest_type: "Adult", user_id: @user.id, compoundname: "#{@user.first}" + "#{@user.last}", team_id: @user.team_id)
				if @guest.save
				else
					fail
				end
				# @user.update(:fee_status => false)
				session[:user_id] = @user.id
		  		# session[:payed] = false
		  		# Default Mailer
		  		# UserMailer.welcome_email(@user).deliver_later(wait: 1.day)
		  		flash[:errors] = nil
				redirect_to '/guests/show'
			else
				session[:modalFail] = true
				flash[:errors] = @user.errors.full_messages
				redirect_to :back
			end					
		else
			@team = Team.new(team_params)
			if params['team']['exempt'] == "true"
				@team.exempt = true
			else
				@team.exempt = false
			end
			@team.mail_confirmation = false
			@team.save
			@user = User.new(user_params)
			@user.team_id = @team.id
				if @user.save
					@guest = Guest.new(first: @user.first, last: @user.last, guest_type: "Adult", user_id: @user.id, compoundname: "#{@user.first}" + "#{@user.last}", team_id: @user.team_id)
					if @guest.save
					else
						fail
					end
					# @user.update(:fee_status => false)
					session[:user_id] = @user.id
			  		# session[:payed] = false
			  		# Default Mailer
			  		UserMailer.welcome_email(@user).deliver_now
			  		flash[:errors] = nil
					redirect_to '/guests/show'
				else
					session[:modalFail] = true
					flash[:errors] = @user.errors.full_messages
					redirect_to :back
				end
			@guest = Guest.new(first: @user.first, last: @user.last, guest_type: "Adult", user_id: @user.id, compoundname: "#{@user.first}" + "#{@user.last}", team_id: @user.team_id)
		end
	end
	def root
		# if session[:user_id] == nil
		# 	redirect_to '/users/new'
		# else
		# 	puts session[:user_id]
		# 	@user = User.find(session[:user_id])
		# end
	end
  	def user_params
  		params.require(:user).permit(:first, :last, :email, :team, :fee_status, :password, :password_confirmation, :team_id) 
  	end
  	def team_params
  		params.require(:team).permit(:name, :conf_num, :exempt)
  	end
  	def edit
  		@user = User.find(session[:user_id])
  	end
   	def update
  		@user = User.find(session[:user_id])
	    if @user.update(user_params)
	    	flash[:errors] = nil
	    else
	    	flash[:errors] = @user.errors.full_messages
	    end
	    redirect_to :back
  	end
  	def teamupdate
  		@user = User.find(session[:user_id])
  		@team = @user.team
  		@team.name = params['name']
  		if @team.save
	    	flash[:errors] = nil
	    else
	    	flash[:errors] = @user.errors.full_messages
	    end
	    redirect_to :back
  	end
  	def transactions
  		@transactions = Transaction.where(user_id: session[:user_id]).order("created_at DESC")
  		@user = User.find(session[:user_id])
  	end
end

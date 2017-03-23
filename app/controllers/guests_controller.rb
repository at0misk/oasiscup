class GuestsController < ApplicationController
	before_action :authenticate_user!
	def new
		@user = User.find(session[:user_id])
		if @user.guests != nil
			@guests = @user.guests
		end
	end
	def create
		# @guest = Guest.new
		# @guest.first = params['guest']['first']
		# @guest.last = params['guest']['last']
		# @guest.guest_type = params['guest']['type']
		# @guest.user_id = session[:user_id]
		# @guest.save
		guestErr = false
		params['guest'].each do |key, val|
			if val == ''
				flash[:errors] = "All fields must be filled out"
				guestErr = true
			end
		end
		if guestErr == true
			redirect_to :back
		else
		compound = ''
		x = 0
		params['guest'].each do |key, val|
			if x % 2 == 0 && x != 0
				@guest.guest_type = val
				@guest.user_id = session[:user_id]
				@guest.save
					x = 0
					compound = ''
					next
			elsif x == 0
				@guest = Guest.new
				# puts 'pushing val'
				@guest.first = val
				compound << @guest.first
				puts @guest.first
				x = x+1
			elsif x == 1
				@guest.last = val
				compound << @guest.last
				@guest.compoundname = compound
				puts @guest.last
				x = x+1
			end
		end
		redirect_to '/guests/show'
		end
	end
	def show
		@guests = Guest.where(user_id: session[:user_id])
	end
  	# def guest_params
	  # 	# params.require(:guest).permit(:first, :last, :type) 
  	# end
  	def delete
  		Guest.destroy(params[:id])
  		redirect_to :back
  	end
  	def update
  		@guest = Guest.find(params[:id])
  		@guest.first = params['first']
  		@guest.last = params['last']
  		@guest.guest_type = params['guest_type']
  		@guest.save
  		redirect_to :back
  	end
end

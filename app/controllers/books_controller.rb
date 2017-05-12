class BooksController < ApplicationController
  helper :authorize_net
	before_action :authenticate_user!
	def create
		@book = Book.new(booked_room_params)
		if @book.save
			Room.destroy(params[:id])
			redirect_to '/booked'
		else
			flash[:errors] = @booked.errors.full_messages
			redirect_to :back
		end
	end
	def cancel
		@book = Book.find(params[:id])
		@room = Room.new
		@room.hotel_id = @book.hotel_id
		@room.price = @book.price
		@room.number = @book.number
		@room.smoking = @book.smoking
		@room.room_type = @book.room_type
		@room.occupancy_a = @book.occupancy_a
		@room.occupancy_c = @book.occupancy_c
		@room.save
		Book.destroy(params[:id])
		@user = User.find(session[:user_id])
		if @user.user_balance
			if @user.user_balance == params['deduct'].to_f
				@user.update_attribute(:user_balance, nil)
			else
			@currentBalance = @user.user_balance
			@user.update_attribute(:user_balance, (@currentBalance - params['deduct'].to_f))
			end
		end
		redirect_to :back
	end
  	def booked_room_params
  		params.require(:book).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type, :occupancy_a, :team_id, :occupancy_c) 
  	end
  	def room_params
  		params.require(:room).permit(:hotel_id, :price, :number, :smoking, :room_type, :occupancy_a, :occupancy_c) 
  	end
  	def booked
  		if flash[:charged]
  			flash[:charged] = "Thank you, a confirmation email has been sent"
  		end
  		@user = User.find(session[:user_id])
  		@team = @user.team
 		if @team.books.length > 0
			@team.books.each do |val|
				if val.user_id != session[:user_id]
					flash[:team_has_rooms] = true
				end
			end
		end
		if @team.exempt
			if @team.books.length < 5
				session[:exemptRoomsNeeded] = true
			elsif @team.books.length >= 5
				session[:exemptRoomsNeeded] = false
			end
		else
			if @team.books.length < 8
				session[:roomsNeeded] = true
			elsif @team.books.length >= 8
				session[:roomsNeeded] = false
			end
		end
  		@booked_rooms = Book.where(team_id: @team.id)
  		@user_rooms = Book.where(user_id: @user.id)
  		@total = 0
  		@tax = 0
  			@booked_rooms.each do |val|
  			@roomTax = val.hotel.tax
			@tax += @roomTax * val.price
  				@total += val.price
  			end
  		@total_user = 0
  		@tax_user = 0
  			@user_rooms.each do |val|
  				@userRoomTax = val.hotel.tax
  				@tax_user += @userRoomTax * val.price
  				@total_user += val.price
  			end
    	# @sim_transaction = AuthorizeNet::SIM::Transaction.new('9CPC3p3r8J', '85GL7ApYu8v533sU', @user.user_balance, :relay_url => "http://www.oasiscup.com/payments/relay_response")
  	end
  	def teams
  		@user = User.find(session[:user_id])
  		@team = @user.team
		if @team.exempt
			if @team.books.length < 5
				session[:exemptRoomsNeeded] = true
			elsif @team.books.length >= 5
				session[:exemptRoomsNeeded] = false
			end
		else
			if @team.books.length < 8
				session[:roomsNeeded] = true
			elsif @team.books.length >= 8
				session[:roomsNeeded] = false
			end
		end
  		@booked_rooms = Book.where(team_id: @team.id)
  		# @user_rooms = Book.where(user_id: @user.id)
  		@total = 0
  		@tax = 0
  			@booked_rooms.each do |val|
  			@roomTax = val.hotel.tax
			@tax += @roomTax * val.price
  				@total += val.price
  			end
  	end
end

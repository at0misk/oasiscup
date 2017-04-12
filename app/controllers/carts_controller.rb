class CartsController < ApplicationController
	before_action :authenticate_user!
	def create
		session[:from_cart] = true
		@user = User.find(session[:user_id])
		# @cart = Cart.new(cart_params)
		# @cart.team_id = @user.team.id
		params['amount'].to_i.times do
			@x = Hotel.find(params['hotel_id']).rooms.where(room_type: params['room_type']).first.number.to_i
			@cart = Cart.new
			@cart.hotel_id = params['hotel_id']
			@cart.user_id = session[:user_id]
			@cart.price = params['price']
			@cart.number = @x
			@cart.smoking = params['smoking']
			@cart.room_type = params['room_type']
			@cart.occupancy_a = params['occupancy_a']
			@cart.occupancy_c = params['occupancy_c']
			@cart.team_id = @user.team.id
			if @cart.save
				flash[:cart_created] = "Added to cart!"
			else
				flash[:errors] = @cart.errors.full_messages
			end
			Room.where(hotel_id: params['hotel_id'], number: @x).destroy_all
		end
		redirect_to :back
	end
	def cancel
	  	@cart = Cart.find(params[:id])
		@room = Room.new
		@room.hotel_id = @cart.hotel_id
		@room.price = @cart.price
		@room.number = @cart.number
		@room.smoking = @cart.smoking
		@room.room_type = @cart.room_type
		@room.occupancy_a = @cart.occupancy_a
		@room.occupancy_c = @cart.occupancy_c
		@room.save
		if Cart.destroy(params[:id])
		else
		end
		redirect_to :back
	end
	def view
		session[:childCount] = 0
		session[:adultCount] = 0
		@user = User.find(session[:user_id])
		@booked_rooms = @user.books
		@team = @user.team
		if @team.exempt
			if @team.books.length < 5
				session[:exemptRoomsNeeded] = true
			elsif @team.books.length >= 5
				session[:exemptRoomsNeeded] = false
			end
		else
			if @team.books.length < 10
				session[:roomsNeeded] = true
			elsif @team.books.length >= 10
				session[:roomsNeeded] = false
			end
		end
		if @user.guests.empty?
			@noGuests = true
		else
			@noGuests = false
			@user.guests.each do |val|
				if val.guest_type == "Child"
					session[:childCount] += 1
				elsif val.guest_type == "Adult"
					session[:adultCount] += 1
				end
			end
			if session[:childCount] > 0
				@guestCountA = session[:adultCount]
				@guestCountC = session[:childCount]
			end
			@guestCount = @user.guests.length
		end
	    # gon.client_token = generate_client_token
	    @token = gon.client_token
		@cart_rooms = Cart.where(user_id: @user.id)
		@total = 0
		@tax = 0
		@cart_rooms.each do |val|
			@roomTax = val.hotel.tax
			@tax += @roomTax * val.price
			@total += val.price
			if val.occupancy_c
				session[:c_found] = true 
			end
		end
	end
	# def checkout
	# 	@user = User.find(session[:user_id])
	# 	# @result = Braintree::Transaction.sale(
	# 	# 	:amount => params['total'],
	# 	# 	:payment_method_nonce => 'fake-valid-nonce',
 #  #           customer: {
 #  #             first_name: @user.first,
 #  #             last_name: @user.last,
 #  #             email: @user.email
 #  #           },
 #  #           options: {
 #  #             store_in_vault: true,
	# 	# 	  :submit_for_settlement => true
 #  #           }
	# 	# )
	# 	if @result.success?
	# 		@cart = Cart.where(user_id: session[:user_id])
	# 		@cart.each do |val|
	# 			@booked = Book.new
	# 			@booked.hotel_id = val.hotel_id
	# 			@booked.user_id = val.user_id
	# 			@booked.price = val.price
	# 			@booked.number = val.number
	# 			@booked.smoking = val.smoking
	# 			@booked.room_type = val.room_type
	# 			@booked.occupancy_a = val.occupancy_a
	# 			@booked.save
	# 			Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
	# 			Cart.where(user_id: session[:user_id]).destroy_all
	# 		end
	# 		redirect_to '/booked'
	# 	else
	# 		flash[:alert] = "Something went wrong while processing your transaction. Please try again!"
	# 		gon.client_token = generate_client_token
	# 		redirect_to :back
	# 	end
	# end

  	def cart_params
  		# params.require(:cart).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type, :occupancy_a, :team_id, :occupancy_c) 
  	end
	# private
	# def generate_client_token
	# 	Braintree::ClientToken.generate
	# end
end

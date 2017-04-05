class CartsController < ApplicationController
	before_action :authenticate_user!
	def create
		session[:from_cart] = true
		@user = User.find(session[:user_id])
		@cart = Cart.new(cart_params)
		@cart.team_id = @user.team.id
		if @cart.save
			redirect_to :back
		else
			flash[:errors] = @cart.errors.full_messages
			redirect_to :back
		end
	end
	def cancel
		Cart.destroy(params[:id])
		redirect_to :back
	end
	def view
		session[:childCount] = 0
		session[:adultCount] = 0
		@user = User.find(session[:user_id])
		@team = @user.team
		if @user.team.guests.empty?
			@noGuests = true
		else
			@noGuests = false
			@user.team.guests.each do |val|
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
			@guestCount = @user.team.guests.length
		end
	    gon.client_token = generate_client_token
	    @token = gon.client_token
		@cart_rooms = Cart.where(team_id: @user.team.id)
		@total = 0
		@cart_rooms.each do |val|
			@total += val.price
			if val.occupancy_c
				session[:c_found] = true 
			end
		end
	end
	def checkout
		@user = User.find(session[:user_id])
		@result = Braintree::Transaction.sale(
			:amount => params['total'],
			:payment_method_nonce => 'fake-valid-nonce',
            customer: {
              first_name: @user.first,
              last_name: @user.last,
              email: @user.email
            },
            options: {
              store_in_vault: true,
			  :submit_for_settlement => true
            }
		)
		if @result.success?
			@cart = Cart.where(user_id: session[:user_id])
			@cart.each do |val|
				@booked = Book.new
				@booked.hotel_id = val.hotel_id
				@booked.user_id = val.user_id
				@booked.price = val.price
				@booked.number = val.number
				@booked.smoking = val.smoking
				@booked.room_type = val.room_type
				@booked.occupancy_a = val.occupancy_a
				@booked.save
				Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
				Cart.where(user_id: session[:user_id]).destroy_all
			end
			redirect_to '/booked'
		else
			flash[:alert] = "Something went wrong while processing your transaction. Please try again!"
			gon.client_token = generate_client_token
			redirect_to :back
		end
	end

  	def cart_params
  		params.require(:cart).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type, :occupancy_a, :team_id, :occupancy_c) 
  	end
	private
	def generate_client_token
		Braintree::ClientToken.generate
	end
end

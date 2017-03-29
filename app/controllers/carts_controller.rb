class CartsController < ApplicationController
	before_action :authenticate_user!
	def create
		@cart = Cart.new(cart_params)
		if @cart.save
			redirect_to "/hotels/#{@cart.hotel.id}"
		else
			flash[:errors] = @cart.errors.full_messages
			redirect_to '/cart'
		end
	end
	def cancel
		Cart.destroy(params[:id])
		redirect_to :back
	end
	def view
		@user = User.find(session[:user_id])
		if @user.guests.empty?
			@noGuests = true
		else
			@noGuests = false
		end
	    gon.client_token = generate_client_token
	    @token = gon.client_token
		@cart_rooms = Cart.where(user_id: session[:user_id])
		@total = 0
		@cart_rooms.each do |val|
			@total += val.price
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
  		params.require(:cart).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type) 
  	end
	private
	def generate_client_token
		Braintree::ClientToken.generate
	end
end

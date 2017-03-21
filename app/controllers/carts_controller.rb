class CartsController < ApplicationController
	def create
		@cart = Cart.new(cart_params)
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
		@cart_rooms = Cart.where(user_id: session[:user_id])
		@total = 0
		@cart_rooms.each do |val|
			@total += val.price
		end
	end
	def checkout
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
			@room = Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		@cart = Cart.where(user_id: session[:user_id]).destroy_all
		redirect_to :back
	end
  	def cart_params
  		params.require(:cart).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type) 
  	end
end

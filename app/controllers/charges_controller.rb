class ChargesController < ApplicationController
	def create
	  # Amount in cents
	  # puts params['amount']
	  # fail
	  @amount = params['amount'].to_i
	  @user = User.find(session[:user_id])
	  @cart = Cart.where(user_id: session[:user_id])
	  customer = Stripe::Customer.create(
	    :email => params[:stripeEmail],
	    :source  => params[:stripeToken]
	  )

	  charge = Stripe::Charge.create(
	    :customer    => customer.id,
	    :amount      => @amount,
	    :description => 'Oasis Cup Booking, Customer ID #' + session[:user_id].to_s,
	    :currency    => 'usd'
	  )
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

		@transaction = Transaction.new(user_id: session[:user_id], total: (@amount/100).to_f)
		@transaction.save
		
		redirect_to '/booked'
	end
end

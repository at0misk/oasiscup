class BooksController < ApplicationController
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
		@room.save
		Book.destroy(params[:id])
		redirect_to :back
	end
  	def booked_room_params
  		params.require(:book).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type) 
  	end
  	def room_params
  		params.require(:room).permit(:hotel_id, :price, :number, :smoking, :room_type) 
  	end
  	def booked
  		@booked_rooms = Book.where(user_id: session[:user_id])
  		@total = 0
  			@booked_rooms.each do |val|
  				@total += val.price
  			end
  	end
end

class BooksController < ApplicationController
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
		redirect_to :back
	end
  	def booked_room_params
  		params.require(:book).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type, :occupancy_a, :team_id, :occupancy_c) 
  	end
  	def room_params
  		params.require(:room).permit(:hotel_id, :price, :number, :smoking, :room_type, :occupancy_a, :occupancy_c) 
  	end
  	def booked
  		@user = User.find(session[:user_id])
  		@team = @user.team
  		@booked_rooms = Book.where(team_id: @team.id)
  		@total = 0
  			@booked_rooms.each do |val|
  				@total += val.price
  			end
  	end
end

class RoomsController < ApplicationController
	def new
	end
	def create
		@room = Room.new(room_params)
		if @room.save
			redirect_to "/rooms/#{@room.id}"
		else
			flash[:errors] = @room.errors.full_messages
			redirect_to :back
		end
	end
	def view
		@room = Room.find(params[:id])
	end
  	def room_params
  		params.require(:room).permit(:hotel_id, :price, :number, :smoking, :room_type) 
  	end
  	def all
  		@rooms = Room.all
  	end
end

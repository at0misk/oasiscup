class HotelsController < ApplicationController
	def new
	end
	def create
		@hotel = Hotel.new(hotel_params)
		if @hotel.save
			redirect_to "/hotels/#{@hotel.id}"
		else
			flash[:errors] = @hotel.errors.full_messages
			redirect_to :back
		end
	end
	def view
		@hotel = Hotel.find(params[:id])
	end
  	def hotel_params
  	params.require(:hotel).permit(:name, :address) 
  	end
  	def all
  		@hotels = Hotel.all
  	end
end

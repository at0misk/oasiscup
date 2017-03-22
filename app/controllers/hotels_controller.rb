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
		if session[:searching] == true
			@rooms = @@roomSwitch
		else
  			@rooms = @hotel.rooms
  		end
  		session[:searching] = false
	end
  	def hotel_params
  	params.require(:hotel).permit(:name, :address) 
  	end
  	def all
  		@hotels = Hotel.all
  	end
  	def search
  		searchArr = []
  		session[:searching] = true
  		@hotel = Hotel.find(params[:id])
  		tag_ids = params[:tag_ids]
  		if tag_ids
  			if tag_ids.include? '4'
  				@@roomSwitch = @hotel.rooms.order(:price)
  			else
  				@@roomSwitch = @hotel.rooms
  			end
  			if tag_ids.include? '1'
  				@@roomSwitch.each do |val|
  					if val.room_type == 'Single'
  						searchArr << val
  					end
				end
			end
			if tag_ids.include? '2'
  				@@roomSwitch.each do |val|
  					if val.room_type == 'Double'
  						searchArr << val
  					end
				end
  			end
			if tag_ids.include? '3'
  				@@roomSwitch.each do |val|
  					if val.room_type == 'Suite'
  						searchArr << val
  					end
				end
  			end
 			@@roomSwitch = searchArr
  		else
  			session[:searching] = false
  		end
   		redirect_to "/hotels/#{@hotel.id}"
  	end
end

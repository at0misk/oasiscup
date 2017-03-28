class HotelsController < ApplicationController
	before_action :authenticate_user!
  @@roomSwitch = {}
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
    @cart = Cart.where(user_id: session[:user_id])
    @cartNumberArr = []
    @cart.each do |val|
      @cartNumberArr << val.number
    end
		if session[:searching] == true
			@rooms = @@roomSwitch
      # puts '============'
      # puts @rooms.first
      # fail
		else
  		@rooms = @hotel.rooms
  	end
  		session[:searching] = false
	end
  	def hotel_params
  	params.require(:hotel).permit(:name, :address) 
  	end
  	def all
      if !session[:fromCount]
  		session[:childCount] = 0
  		session[:adultCount] = 1
  		@user = User.find(session[:user_id])
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
      	end
      else
      @user = User.find(session[:user_id])
      # if @user.guests.empty?
      #   @noGuests = true
      # else
      #   @noGuests = false
      #   @user.guests.each do |val|
      #     if val.guest_type == "Child"
      #       session[:childCount] += 1
      #     elsif val.guest_type == "Adult"
      #       session[:adultCount] += 1
      #     end
      #   end
      end
        session[:fromCount] = false
    		@hotels = Hotel.all
  	end
  	def search
  		searchArr = []
  		session[:searching] = true
  		@hotel = Hotel.find(params[:id])
  		tag_ids = params[:tag_ids]
  		if tag_ids
  			if tag_ids.include? '4'
          cheapestOnly = true
  				@@roomSwitch = @hotel.rooms.order(:price)
  			else
  				@@roomSwitch = @hotel.rooms
  			end
  			if tag_ids.include? '1'
          cheapestOnly = false
  				@@roomSwitch.each do |val|
  					if val.room_type == 'Single'
  						searchArr << val
  					end
				end
			end
			if tag_ids.include? '2'
          cheapestOnly = false
  				@@roomSwitch.each do |val|
  					if val.room_type == 'Double'
  						searchArr << val
  					end
				end
  		end
			if tag_ids.include? '3'
          cheapestOnly = false
  				@@roomSwitch.each do |val|
  					if val.room_type == 'Suite'
  						searchArr << val
  					end
				end
  		end
        if cheapestOnly
          @@roomSwitch = @hotel.rooms.order(:price)
        else
   			@@roomSwitch = searchArr
        end
  		else
        @@roomSwitch = @hotel.rooms
  			# session[:searching] = false
  		end
   		redirect_to "/hotels/#{@hotel.id}"
  	end
end

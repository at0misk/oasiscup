class HotelsController < ApplicationController
  require 'will_paginate/array'
	before_action :authenticate_user!
  @@roomSwitch = {} if @@roomSwitch.nil?
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
    if params[:paginate]
      # @rooms = @@roomSwitch
      @rooms = @@roomSwitch.paginate(:page => params[:page], :per_page => 7)
      params[:paginate] = false
    else
  		if session[:searching] == true
  			@rooms = @@roomSwitch.paginate(:page => params[:page], :per_page => 7)
        # puts '============'
        # puts @rooms.first
        # fail
  		else
    		@rooms = @hotel.rooms.order(:price).paginate(:page => params[:page], :per_page => 7)
    	end
    end
  		session[:searching] = false
	end
  def edit
    @hotel = Hotel.find(params[:id])
  end
  def update
    @hotel = Hotel.find(params[:id])
    @hotel.update(hotel_params)
  end
  	def hotel_params
  	params.require(:hotel).permit(:name, :address, :lat, :long, :phone, :city, :state, :zip, :image, :description, :website, :tax, :checkin, :checkout, :resortFee) 
  	end
  	def all
      if !session[:fromCount]
  		session[:childCount] = 0
  		session[:adultCount] = 0
  		@user = User.find(session[:user_id])
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
    		@hotels = Hotel.all.paginate(:page => params[:page], :per_page => 8)
        @hotelsAll = Hotel.all
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
            if val.room_type == 'Double Queens'
              searchArr << val
            end
        end
        @@roomSwitch = Room.where(room_type: "Double Queens").order(:price)
      end
      if tag_ids.include? '3'
          cheapestOnly = false
          @@roomSwitch.each do |val|
            if val.room_type == 'King'
              searchArr << val
            end
        end
        @@roomSwitch = Room.where(room_type: "King").order(:price)
      end
        if cheapestOnly
        @@roomSwitch = @hotel.rooms.order(:price)
        else
   			# @@roomSwitch = searchArr
      #   @@roomSwitch.each do |val|
      #     puts val
      #   end
        # fail
        end
  		else
        @@roomSwitch = @hotel.rooms
  			# session[:searching] = false
  		end
   		redirect_to "/hotels/#{@hotel.id}"
  	end
end

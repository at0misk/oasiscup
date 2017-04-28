class RoomsController < ApplicationController
  require 'will_paginate/array'
  @@roomSwitch = {}
	before_action :authenticate_user!
	def new
	end
  def generate
    if !session[:user_id]
    else
      @user = User.find(session[:user_id])
      if !@user.permod
      else
        x = 1
        1.times do
          @room = Room.new
          @room.number = x
          @room.hotel_id = params[:id]
          @room.smoking = "No"
          @room.room_type = "King"
          @room.price = 249.95
          @room.occupancy_a = 4
          # @room.occupancy_c = 
          @room.description = ""
          x += 1
          @room.save
        end
      end
    end
    redirect_to '/'
  end
	def create
		@room = Room.new(room_params)
		if @room.save
			redirect_to :back
		else
			flash[:errors] = @room.errors.full_messages
			redirect_to :back
		end
	end
	def view
		@room = Room.find(params[:id])
	end
  	def room_params
  		params.require(:room).permit(:hotel_id, :price, :number, :smoking, :room_type, :occupancy_a, :occupancy_c, :description) 
  	end
  	def all
        @user = User.find(session[:user_id])
        @cart = Cart.where(user_id: session[:user_id])
        @cartNumberArr = []
        @cart.each do |val|
          @cartNumberArr << val.number
        end
        if @user.guests != nil
          session[:childCount] = 0
          session[:adultCount] = 1
          @user.guests.each do |val|
            if val.guest_type == "Child"
              session[:childCount] += 1
            elsif val.guest_type == "Adult"
              session[:adultCount] += 1
            end
          end
        end
        if params[:paginate]
          # @rooms = @@roomSwitch
          @rooms = @@roomSwitch.paginate(:page => params[:page], :per_page => 7)
          params[:paginate] = false
        else
        # if session[:from_cart]
        #   if @@roomSwitch != {}
        #   @rooms = @@roomSwitch.paginate(:page => params[:page], :per_page => 7)
        #   else
        #   @rooms = Room.all.paginate(:page => params[:page], :per_page => 7)
        #   end
        # else
        if session[:price_range] && !session[:searchingAll] 
          # @roomArr = []
          if session[:price_range] == 1
              @hotelIds = Room.where(price: 0..175).order(:price).select('distinct hotel_id').map(&:hotel_id)
              # @hotelIds.each do |val|
                  # @roomTypes = Hotel.find(val).rooms.select('distinct room_type').map(&:room_type)
                  # @roomArr << @roomTypes
              # end
              @rooms = Room.where(price: 0..175).order(:price).paginate(:page => params[:page], :per_page => 7)
          elsif session[:price_range] == 2
              @hotelIds = Room.where(price: 176..250).order(:price).select('distinct hotel_id').map(&:hotel_id)
              @rooms = Room.where(price: 176..250).order(:price).paginate(:page => params[:page], :per_page => 7)
          elsif session[:price_range] == 3
              @hotelIds = Room.where(price: 251..2000).order(:price).select('distinct hotel_id').map(&:hotel_id)
              @rooms = Room.where(price: 251..2000).order(:price).paginate(:page => params[:page], :per_page => 7)
          end
          # session[:price_range] = nil
        else
          if session[:searchingAll] == true
            @rooms = @@roomSwitch.paginate(:page => params[:page], :per_page => 7)
            # puts '============'
            # puts @rooms.first
            # fail
          else
            @hotelIds = Room.all.order(:price).select('distinct hotel_id').map(&:hotel_id)
            @rooms = Room.all.order(:price).paginate(:page => params[:page], :per_page => 7)
          end
          session[:searchingAll] = false
        end
      # end
    end
      @@roomSwitch = @rooms
      params[:paginate] = false
      session[:from_cart] = false
  	end
  	def search
      # @hotelIds = Room.where(price: 176..250).select('distinct hotel_id').map(&:hotel_id)
      # Gets unique hotel ids for price bracket
  		if params[:id] == '1'
  			# @rooms = Room.where(price: 70..120).order(:price)
        session[:price_range] = 1
  		elsif params[:id] == '2'
  			# @rooms = Room.where(price: 120..150).order(:price)
          session[:price_range] = 2
  		elsif params[:id] == '3'
  			# @rooms = Room.where(price: 150..200).order(:price)
        session[:price_range] = 3
  		end
      redirect_to '/rooms'
  	end
  	def count
      session[:price_range] = nil
  		session[:fromCount] = true
  		session[:childCount] = params['child'].to_i
  		session[:adultCount] = params['adult'].to_i
  		redirect_to '/rooms'
  	end
    def searchAll
      session[:searchingAll] = true
      searchArr = []
      session[:childCount] = params['child'].to_i
      session[:adultCount] = params['adult'].to_i
      if session[:price_range] == 1
        @rooms = Room.where(price: 0..175).order(:price)
      elsif session[:price_range] == 2
        @rooms = Room.where(price: 176..250).order(:price)
      elsif session[:price_range] == 3
        @rooms = Room.where(price: 251..2000).order(:price)
      else
        @rooms = Room.all
      end
      tag_ids = params[:tag_ids]
      if tag_ids
        if tag_ids.include? '4'
          cheapestOnly = true
          @@roomSwitch = @rooms.order(:price)
        else
          @@roomSwitch = @rooms.order(:price)
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
          @@roomSwitch = @rooms.order(:price)
        else
        # @@roomSwitch = searchArr
        end
      else
        @@roomSwitch = @rooms.order(:price)
        # session[:searchingAll] = false
      end
      redirect_to :back
    end
end

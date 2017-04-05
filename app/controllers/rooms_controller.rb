class RoomsController < ApplicationController
  @@roomSwitch
	before_action :authenticate_user!
	def new
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
  		params.require(:room).permit(:hotel_id, :price, :number, :smoking, :room_type, :occupancy_a, :occupancy_c) 
  	end
  	def all
        @user = User.find(session[:user_id])
        @cart = Cart.where(user_id: session[:user_id])
        @cartNumberArr = []
        @cart.each do |val|
          @cartNumberArr << val.number
        end
        if session[:from_cart]
          @rooms = @@roomSwitch
        else
        if session[:price_range] && !session[:searchingAll] 
          if session[:price_range] == 1
              @rooms = Room.where(price: 0..175).order(:price).paginate(:page => params[:page], :per_page => 7)
          elsif session[:price_range] == 2
              @rooms = Room.where(price: 176..250).order(:price).paginate(:page => params[:page], :per_page => 7)
          elsif session[:price_range] == 3
              @rooms = Room.where(price: 251..2000).order(:price).paginate(:page => params[:page], :per_page => 7)
          end
          # session[:price_range] = nil
        else
          if session[:searchingAll] == true
            @rooms = @@roomSwitch
            # puts '============'
            # puts @rooms.first
            # fail
          else
            @rooms = Room.paginate(:page => params[:page], :per_page => 7)
            # if @user.guests != nil
            #   @user.guests.each do |val|
            #     if val.guest_type == "Child"
            #       session[:childCount] += 1
            #     elsif val.guest_type == "Adult"
            #       session[:adultCount] += 1
            #     end
            #   end
            # end
          end
          session[:searchingAll] = false
        end
      end
      @@roomSwitch = @rooms
      session[:from_cart] = false
  	end
  	def search
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
        @rooms = Room.where(price: 70..120).order(:price).paginate(:page => params[:page], :per_page => 7)
      elsif session[:price_range] == 2
        @rooms = Room.where(price: 120..150).order(:price).paginate(:page => params[:page], :per_page => 7)
      elsif session[:price_range] == 3
        @rooms = Room.where(price: 150..200).order(:price).paginate(:page => params[:page], :per_page => 7)
      else
        @rooms = Room.all
      end
      tag_ids = params[:tag_ids]
      if tag_ids
        if tag_ids.include? '4'
          cheapestOnly = true
          @@roomSwitch = @rooms.order(:price).paginate(:page => params[:page], :per_page => 7)
        else
          @@roomSwitch = @rooms.paginate(:page => params[:page], :per_page => 7)
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
          @@roomSwitch = @rooms.order(:price).paginate(:page => params[:page], :per_page => 7)
        else
        @@roomSwitch = searchArr.paginate(:page => params[:page], :per_page => 7)
        end
      else
        @@roomSwitch = @rooms.paginate(:page => params[:page], :per_page => 7)
        # session[:searchingAll] = false
      end
      redirect_to :back
    end
end

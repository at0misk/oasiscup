class CartsController < ApplicationController
  helper :authorize_net
	before_action :authenticate_user!
	def create
		session[:from_cart] = true
		@user = User.find(session[:user_id])
		# @cart = Cart.new(cart_params)
		# @cart.team_id = @user.team.id
		params['amount'].to_i.times do
			@x = Hotel.find(params['hotel_id']).rooms.where(room_type: params['room_type']).first.number.to_i
			@cart = Cart.new
			@cart.hotel_id = params['hotel_id']
			@cart.user_id = session[:user_id]
			@cart.price = params['price']
			@cart.number = @x
			@cart.smoking = params['smoking']
			@cart.room_type = params['room_type']
			@cart.occupancy_a = params['occupancy_a']
			@cart.occupancy_c = params['occupancy_c']
			@cart.team_id = @user.team.id
			if @cart.save
				flash[:cart_created] = "Added to cart!"
				Room.where(hotel_id: params['hotel_id']).first.destroy
			else
				flash[:errors] = @cart.errors.full_messages
			end
		end
		redirect_to :back
	end
	def cancel
	  	@cart = Cart.find(params[:id])
		@room = Room.new
		@room.hotel_id = @cart.hotel_id
		@room.price = @cart.price
		@room.number = @cart.number
		@room.smoking = @cart.smoking
		@room.room_type = @cart.room_type
		@room.occupancy_a = @cart.occupancy_a
		@room.occupancy_c = @cart.occupancy_c
		@room.save
		if Cart.destroy(params[:id])
		else
		end
		redirect_to :back
	end
	def view
		session[:childCount] = 0
		session[:adultCount] = 0
		@user = User.find(session[:user_id])
		@booked_rooms = @user.books
		@team = @user.team
		if @team.books.length > 0
			@team.books.each do |val|
				if val.user_id != session[:user_id]
					flash[:team_has_rooms] = true
				else
					flash[:team_has_rooms] = false
				end
			end
		end
		if @team.exempt
			if @team.books.length < 5
				session[:exemptRoomsNeeded] = true
			elsif @team.books.length >= 5
				session[:exemptRoomsNeeded] = false
			end
		else
			if @team.books.length < 7
				session[:roomsNeeded] = true
			elsif @team.books.length >= 7
				session[:roomsNeeded] = false
			end
		end
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
			if session[:childCount] > 0
				@guestCountA = session[:adultCount]
				@guestCountC = session[:childCount]
			end
			@guestCount = @user.guests.length
		end
	    gon.client_token = generate_client_token
	    @token = gon.client_token
		@cart_rooms = Cart.where(user_id: @user.id)
		@total = 0
		@tax = 0
		@cart_rooms.each do |val|
			@roomTax = val.hotel.tax
			@tax += @roomTax * val.price
			@total += val.price
			@total += @roomTax * val.price
			if val.occupancy_c
				session[:c_found] = true 
			end
		end
    	# @sim_transaction_deposit = AuthorizeNet::SIM::Transaction.new('9CPC3p3r8J', '85GL7ApYu8v533sU', @total, :relay_url => "http://www.oasiscup.com/payments/relay_response")
    	# @sim_transaction = AuthorizeNet::SIM::Transaction.new('9CPC3p3r8J', '85GL7ApYu8v533sU', (@total*3), :relay_url => "http://www.oasiscup.com/payments/relay_response")
	end
	def checkout
	  @user = User.find(session[:user_id])
		@user.update_attribute(:down_payment_status, false)
		@user.save
	  @team = @user.team
	  @cart = Cart.where(user_id: @user.id)
	  @books = Book.where(user_id: @user.id)
	  if @books.length > 0
	  	@old_balance = @user.user_balance
	  	@param_balance = BigDecimal.new(params['balance'])
	  	@user.update_attribute(:user_balance, (@param_balance + @old_balance))
	  else
	  	@user.update_attribute(:user_balance, params['balance'])
	  end
		flash[:charged] = true
		@total = 0
		@tax = 0
		@cart.each do |val|
			@roomTax = val.hotel.tax
			@tax += @roomTax * val.price
			@total += val.price
			@total += @roomTax * val.price
		end
		@current_cart_total = @cart.sum(:price)
	  	@i = 0
		@cart.each do |val|
			@booked = Book.new
			@booked.hotel_id = val.hotel_id
			@booked.user_id = val.user_id
			@booked.price = val.price
			@booked.number = val.number
			@booked.smoking = val.smoking
			@booked.room_type = val.room_type
			@booked.occupancy_a = val.occupancy_a
			@booked.occupancy_c = val.occupancy_c
			@booked.team_id = @user.team.id
			@booked.paid_status = false
			# @booked.transaction_id = @t.id
			# if session[:relay_transaction_type] == 'down payment'
			# 	@booked.paid_status = false
			# elsif session[:relay_transaction_type] == 'full'
			# 	@booked.paid_status = true
			# end
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@booked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@i}"
			@booked.save
			@i += 1
		end
		UserMailer.payment_pending(@user).deliver_now
		@admins = User.where(team_id: 18)
		@admins.each do |val|
			UserMailer.admin_payment_pending(@user, val).deliver_now
		end
		Cart.where(user_id: @user.id).destroy_all
		redirect_to '/booked'
	end
	def paid_full
		@user = User.find(params['u_id'])
		@team = @user.team
		@user.update_attribute(:user_balance, nil)
		@user.save
		@book = Book.where(user_id: @user.id)
		@transaction = Transaction.new(user_id: session[:user_id], total: params['amount'], transaction_code: "#AT-#{session[:user_id]}0#{Date.today.to_s}-", tax: params['tax'].to_f)
		if @transaction.save
			@newcode = @transaction.transaction_code + @transaction.id.to_s
			@transaction.update_attribute(:transaction_code, @newcode)
			@t = Transaction.last
	  		flash[:charged] = "Thank you, a confirmation email has been sent"
		else
			flash[:errors] = "Something went wrong"
			redirect_to :back
		end
		@i = 0
		@book.each do |val|
			@tbooked = Tbook.new
			@tbooked.hotel_id = val.hotel_id
			@tbooked.user_id = val.user_id
			@tbooked.price = val.price
			@tbooked.number = val.number
			@tbooked.smoking = val.smoking
			@tbooked.room_type = val.room_type
			@tbooked.occupancy_a = val.occupancy_a
			@tbooked.occupancy_c = val.occupancy_c
			@tbooked.team_id = @user.team.id
			@tbooked.transaction_id = @t.id
			@tbooked.paid_status = true
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@tbooked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@i}"
			@tbooked.save
			@i += 1
			# Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		@book.update_all(:paid_status => true)
		# @book.save
		@transaction.transaction_type = "Paid In Full"
		@transaction.save
		@transaction_type = 'paid in full'
		# @admin = false
		# UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
		@admin = true
		UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
		@admin = false
		# Paid in full from the get go - Send Emails with guestlist and confirmation
		if @team.exempt
			if @team.books.length < 5
				session[:exemptRoomsNeeded] = true
			elsif @team.books.length >= 5
				session[:exemptRoomsNeeded] = false
				@team.users.each do |val|
					puts 'mailing'
					puts "#{val.first}"
					@admins = User.where(team_id: 18)
					@admins.each do |adminval|
						UserMailer.tournament_confirmation(val, adminval, @transaction).deliver_now
					end
				end
				@team.mail_confirmation = true
				@team.save
			end
		else
			if @team.books.length < 7
				session[:roomsNeeded] = true
			elsif @team.books.length >= 7
				session[:roomsNeeded] = false
				@team.users.each do |val|
					puts 'mailing'
					puts "#{val.first}"
					@admins = User.where(team_id: 18)
					@admins.each do |adminval|
						UserMailer.tournament_confirmation(val, adminval, @transaction).deliver_now
					end
				end
				@team.mail_confirmation = true
				@team.save
			end
		end
		redirect_to :back
	end
	def first_night
		@user = User.find(params['u_id'])
		@team = @user.team
		@amountForBalance = params['amount'].to_f
		@amountForBalance = @amountForBalance*2
		@user.update_attribute(:user_balance, @amountForBalance)
		@user.save
		@user.update_attribute(:down_payment_status, true)
		@user.save
		@book = Book.where(user_id: @user.id)
		@transaction = Transaction.new(user_id: session[:user_id], total: params['amount'], transaction_code: "#AT-#{session[:user_id]}0#{Date.today.to_s}-", tax: params['tax'].to_f)
		if @transaction.save
			@newcode = @transaction.transaction_code + @transaction.id.to_s
			@transaction.update_attribute(:transaction_code, @newcode)
			@t = Transaction.last
	  		flash[:charged] = "Thank you, a confirmation email has been sent"
		else
			flash[:errors] = "Something went wrong"
			redirect_to :back
		end
		@i = 0
		@book.each do |val|
			@tbooked = Tbook.new
			@tbooked.hotel_id = val.hotel_id
			@tbooked.user_id = val.user_id
			@tbooked.price = val.price
			@tbooked.number = val.number
			@tbooked.smoking = val.smoking
			@tbooked.room_type = val.room_type
			@tbooked.occupancy_a = val.occupancy_a
			@tbooked.occupancy_c = val.occupancy_c
			@tbooked.team_id = @user.team.id
			@tbooked.transaction_id = @t.id
			@tbooked.paid_status = false
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@tbooked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@i}"
			@tbooked.save
			@i += 1
			# Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		@transaction.transaction_type = "Down Payment"
		@transaction.save
		@transaction_type = 'down payment'
		@admin = false
		UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
		@admin = true
		UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
		# Paid in full from the get go - Send Emails with guestlist and confirmation
		if @team.exempt
			if @team.books.length < 5
				session[:exemptRoomsNeeded] = true
			elsif @team.books.length >= 5
				session[:exemptRoomsNeeded] = false
				@team.users.each do |val|
					puts 'mailing'
					puts "#{val.first}"
					# UserMailer.confirmation_email(val).deliver_now
				end
				@team.mail_confirmation = true
				@team.save
			end
		else
			if @team.books.length < 7
				session[:roomsNeeded] = true
			elsif @team.books.length >= 7
				session[:roomsNeeded] = false
				@team.users.each do |val|
					puts 'mailing'
					puts "#{val.first}"
					# UserMailer.confirmation_email(val).deliver_now
				end
				@team.mail_confirmation = true
				@team.save
			end
		end
		redirect_to :back
	end
	def paid_balance
		@user = User.find(params['u_id'])
		@team = @user.team
		@user.update_attribute(:user_balance, nil)
		@user.save
		@book = Book.where(user_id: @user.id)
		@transaction = Transaction.new(user_id: session[:user_id], total: params['amount'], transaction_code: "#AT-#{session[:user_id]}0#{Date.today.to_s}-", tax: params['tax'].to_f)
		if @transaction.save
			@newcode = @transaction.transaction_code + @transaction.id.to_s
			@transaction.update_attribute(:transaction_code, @newcode)
			@t = Transaction.last
	  		flash[:charged] = "Thank you, a confirmation email has been sent"
		else
			flash[:errors] = "Something went wrong"
			redirect_to :back
		end
		@i = 0
		@book.each do |val|
			@tbooked = Tbook.new
			@tbooked.hotel_id = val.hotel_id
			@tbooked.user_id = val.user_id
			@tbooked.price = val.price
			@tbooked.number = val.number
			@tbooked.smoking = val.smoking
			@tbooked.room_type = val.room_type
			@tbooked.occupancy_a = val.occupancy_a
			@tbooked.occupancy_c = val.occupancy_c
			@tbooked.team_id = @user.team.id
			@tbooked.transaction_id = @t.id
			@tbooked.paid_status = true
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@tbooked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@i}"
			@tbooked.save
			@i += 1
			# Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		@book.update_all(:paid_status => true)
		@transaction.transaction_type = "Paid Balance"
		@transaction.save
		@transaction_type = 'paid balance'
		@admin = true
		UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
		@admin = false
		# Paid in full from the get go - Send Emails with guestlist and confirmation
		if @team.exempt
			if @team.books.length < 5
				session[:exemptRoomsNeeded] = true
			elsif @team.books.length >= 5
				session[:exemptRoomsNeeded] = false
				@team.users.each do |val|
					puts 'mailing'
					puts "#{val.first}"
					UserMailer.tournament_confirmation(val, @transaction).deliver_now
				end
				@team.mail_confirmation = true
				@team.save
			end
		else
			if @team.books.length < 7
				session[:roomsNeeded] = true
			elsif @team.books.length >= 7
				session[:roomsNeeded] = false
				@team.users.each do |val|
					puts 'mailing'
					puts "#{val.first}"
					UserMailer.tournament_confirmation(val, @transaction).deliver_now
				end
				@team.mail_confirmation = true
				@team.save
			end
		end
		redirect_to :back
	end
  	def cart_params
  		# params.require(:cart).permit(:hotel_id, :user_id, :price, :number, :smoking, :room_type, :occupancy_a, :team_id, :occupancy_c) 
  	end
	private
	def generate_client_token
		Braintree::ClientToken.generate
	end
end

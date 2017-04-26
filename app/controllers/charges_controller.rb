class ChargesController < ApplicationController
	def create
	  # Amount in cents
	  # puts params['amount']
	  # fail
	  @amount = params['amount'].to_i
	  @user = User.find(session[:user_id])
	  @team = @user.team
	  @transamount = params['amount'].to_f/100
	  @cart = Cart.where(user_id: @user.id)
	  customer = Stripe::Customer.create(
	    :email => params[:stripeEmail],
	    :source  => params[:stripeToken]
	  )

		@transaction = Transaction.new(user_id: session[:user_id], total: @transamount, transaction_code: "#AT-#{session[:user_id]}0#{Date.today.to_s}-", tax: params['tax'].to_f)
		if @transaction.save
			@newcode = @transaction.transaction_code + @transaction.id.to_s
			@transaction.update_attribute(:transaction_code, @newcode)
			@t = Transaction.last
	  		flash[:charged] = "Thank you, a confirmation email has been sent"
		else
			flash[:errors] = "Something went wrong"
			redirect_to :back
		end
	  charge = Stripe::Charge.create(
	    :customer    => customer.id,
	    :amount      => @amount,
	    :description => 'Oasis Cup Booking, Order ID ' + @transaction.transaction_code,
	    :currency    => 'usd'
	  )
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
			@booked.transaction_id = @t.id
			if params['balancePaid']
				@booked.paid_status = false
			elsif params['payingFull']
				@booked.paid_status = true
			end
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@booked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@booked.number}"
			@booked.save
			# Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		@cart.each do |val|
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
			if params['balancePaid']
				@tbooked.paid_status = false
			elsif params['payingFull']
				@tbooked.paid_status = true
			end
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@tbooked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@booked.number}"
			@tbooked.save
			# Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		Cart.where(user_id: @user.id).destroy_all
		if params['balancePaid']
			# @remainder = params['totalTotal'].to_f
			# @balance = params['balancePaid'].to_f
			# @balanceSwap = @remainder - @balance
			# puts @balanceSwap
			# fail
			# @balancePaid = (@amount/100)
			# puts @balancePaid
			# @totalToPay = (@transamount*3)
			# puts @totalToPay
			@totalToPay = (@transamount*2)
			puts @totalToPay
			# @balancePaid = @balancePaid.round(2)
			if @user.user_balance && @user.user_balance > 0
				@newBalance = @user.user_balance + @totalToPay
				@user.update_attribute(:user_balance, @newBalance)
			else
				@user.update_attribute(:user_balance, @totalToPay)
			end
			puts @user.user_balance
			# fail
			@transaction.transaction_type = "Down Payment"
			@transaction.save
			@transaction_type = 'down payment'
			@admin = false
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			@admin = true
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			# Made Downpayment - Send Email reminding they still have a balance with their balance
		elsif params['balanceClear']
			@user.update_attribute(:user_balance, nil)
			@rooms = @user.books
			@rooms.each do |val|
				val.update_attribute(:paid_status, true)
			end
			@transaction.transaction_type = "Paid Balance"
			@transaction.save
			@transaction_type = 'paid balance'
			@admin = false
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			@admin = true
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			# Paid Balance - Send Emails with guestlist and confirmation
			if @team.exempt
				if @team.books.length < 5
					session[:exemptRoomsNeeded] = true
				elsif @team.books.length >= 5
					session[:exemptRoomsNeeded] = false
					@team.users.each do |val|
						puts 'mailing'
						puts "#{val.first}"
					end
					@team.mail_confirmation = true
				end
			else
				if @team.books.length < 10
					session[:roomsNeeded] = true
				elsif @team.books.length >= 10
					session[:roomsNeeded] = false
					@team.users.each do |val|
						puts 'mailing'
						puts "#{val.first}"
					end
					@team.mail_confirmation = true
				end
			end
		elsif params['payingFull'] == 'yes'
			@transaction.transaction_type = "Paid In Full"
			@transaction.save
			@transaction_type = 'paid in full'
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
					end
					@team.mail_confirmation = true
					@team.save
				end
			else
				if @team.books.length < 10
					session[:roomsNeeded] = true
				elsif @team.books.length >= 10
					session[:roomsNeeded] = false
					@team.users.each do |val|
						puts 'mailing'
						puts "#{val.first}"
					end
					@team.mail_confirmation = true
					@team.save
				end
			end
		end
		# Manifest Email
	  	# UserMailer.manifest_email(@user).deliver_now
		redirect_to '/booked'
	end

	def relay
	  # Amount in cents
	  # puts params['amount']
	  # fail
	  @amount = session[:relay_ammount].to_i
	  @user = User.find(session[:user_id])
	  @team = @user.team
	  @transamount = session[:relay_ammount].to_f/100
	  @cart = Cart.where(user_id: @user.id)
	  # customer = Stripe::Customer.create(
	  #   :email => params[:stripeEmail],
	  #   :source  => params[:stripeToken]
	  # )
		@total = 0
		@tax = 0
		@cart.each do |val|
			@roomTax = val.hotel.tax
			@tax += @roomTax * val.price
			@total += val.price
			@total += @roomTax * val.price
		end
		@current_cart_total = @cart.sum(:price)
		if (@total * 3).to_f == session[:relay_ammount].to_f
			session[:relay_transaction_type] = 'full'
			@tax = @tax*3
		elsif @total.to_f == session[:relay_ammount].to_f
			session[:relay_transaction_type] = 'down payment'
		elsif @user.user_balance.to_f == session[:relay_ammount].to_f
			session[:relay_transaction_type] = 'paid balance'
		end
		session[:relay_ammount] = ''
		@transaction = Transaction.new(user_id: session[:user_id], total: @amount, transaction_code: "#AT-#{session[:user_id]}0#{Date.today.to_s}-", tax: @tax.to_f)
		if @transaction.save
			@newcode = @transaction.transaction_code + @transaction.id.to_s
			@transaction.update_attribute(:transaction_code, @newcode)
			@t = Transaction.last
	  		flash[:charged] = "Thank you, a confirmation email has been sent"
		else
			flash[:errors] = "Something went wrong"
			redirect_to :back
		end
	  # charge = Stripe::Charge.create(
	  #   :customer    => customer.id,
	  #   :amount      => @amount,
	  #   :description => 'Oasis Cup Booking, Order ID ' + @transaction.transaction_code,
	  #   :currency    => 'usd'
	  # )
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
			@booked.transaction_id = @t.id
			if session[:relay_transaction_type] == 'down payment'
				@booked.paid_status = false
			elsif session[:relay_transaction_type] == 'full'
				@booked.paid_status = true
			end
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@booked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@booked.number}"
			@booked.save
			# Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		@cart.each do |val|
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
			if session[:relay_transaction_type] == 'down payment'
				@tbooked.paid_status = false
			elsif session[:relay_transaction_type] == 'full'
				@tbooked.paid_status = true
			end
			@prefix = Hotel.find(val.hotel_id).conf_prefix
			@tbooked.conf_code = "#{@prefix}#{Date.today.to_s}0#{@booked.number}"
			@tbooked.save
			# Room.where(hotel_id: val.hotel_id, number: val.number).destroy_all
		end
		Cart.where(user_id: @user.id).destroy_all
		# if params['balancePaid']
		if session[:relay_transaction_type] == 'down payment'
			# @remainder = params['totalTotal'].to_f
			# @balance = params['balancePaid'].to_f
			# @balanceSwap = @remainder - @balance
			# puts @balanceSwap
			# fail
			# @balancePaid = (@amount/100)
			# puts @balancePaid
			# @totalToPay = (@transamount*3)
			# puts @totalToPay
			@totalToPay = (@transamount*2)
			puts @totalToPay
			# @balancePaid = @balancePaid.round(2)
			if @user.user_balance && @user.user_balance > 0
				@newBalance = @user.user_balance + @totalToPay
				@user.update_attribute(:user_balance, @newBalance)
			else
				@user.update_attribute(:user_balance, @totalToPay)
			end
			puts @user.user_balance
			# fail
			@transaction.transaction_type = "Down Payment"
			@transaction.save
			@transaction_type = 'down payment'
			@admin = false
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			@admin = true
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			# Made Downpayment - Send Email reminding they still have a balance with their balance
		elsif session[:relay_transaction_type] == 'paid balance'
			@user.update_attribute(:user_balance, nil)
			@rooms = @user.books
			@rooms.each do |val|
				val.update_attribute(:paid_status, true)
			end
			@transaction.transaction_type = "Paid Balance"
			@transaction.save
			@transaction_type = 'paid balance'
			@admin = false
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			@admin = true
			UserMailer.confirmation_email(@user, @transaction_type, @t, @admin).deliver_now
			# Paid Balance - Send Emails with guestlist and confirmation
			if @team.exempt
				if @team.books.length < 5
					session[:exemptRoomsNeeded] = true
				elsif @team.books.length >= 5
					session[:exemptRoomsNeeded] = false
					@team.users.each do |val|
						puts 'mailing'
						puts "#{val.first}"
					end
					@team.mail_confirmation = true
				end
			else
				if @team.books.length < 10
					session[:roomsNeeded] = true
				elsif @team.books.length >= 10
					session[:roomsNeeded] = false
					@team.users.each do |val|
						puts 'mailing'
						puts "#{val.first}"
					end
					@team.mail_confirmation = true
				end
			end
		elsif session[:relay_transaction_type] == 'full'
			@transaction.transaction_type = "Paid In Full"
			@transaction.save
			@transaction_type = 'paid in full'
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
					end
					@team.mail_confirmation = true
					@team.save
				end
			else
				if @team.books.length < 10
					session[:roomsNeeded] = true
				elsif @team.books.length >= 10
					session[:roomsNeeded] = false
					@team.users.each do |val|
						puts 'mailing'
						puts "#{val.first}"
					end
					@team.mail_confirmation = true
					@team.save
				end
			end
		end
		# Manifest Email
	  	# UserMailer.manifest_email(@user).deliver_now
		redirect_to '/booked'
	end
	def authorize
		# require 'rubygems'
		#   require 'authorizenet'
		# include AuthorizeNet::API

		# transaction = Transaction.new('9CPC3p3r8J', '6Ysv3q8Ham2448KG', :gateway => :sandbox)

		# request = CreateTransactionRequest.new

		# request.transactionRequest = TransactionRequestType.new()
		# request.transactionRequest.amount = 16.00
		# request.transactionRequest.payment = PaymentType.new
		# request.transactionRequest.payment.creditCard = CreditCardType.new('4242424242424242','0220','123') 
		# request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction

		# response = transaction.create_transaction(request)

		# if response.messages.resultCode == MessageTypeEnum::Ok
		# puts "Successful charge (auth + capture) (authorization code: #{response.transactionResponse.authCode})"

		# else
		# puts response.messages.messages[0].text
		# puts response.transactionResponse.errors.errors[0].errorCode
		# puts response.transactionResponse.errors.errors[0].errorText
		# raise "Failed to charge card."
		# end
		# redirect_to '/'
	end
end

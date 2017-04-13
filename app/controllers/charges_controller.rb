class ChargesController < ApplicationController
	def create
	  # Amount in cents
	  # puts params['amount']
	  # fail
	  @amount = params['amount'].to_i
	  @user = User.find(session[:user_id])
	  @team = @user.team
	  @cart = Cart.where(user_id: @user.id)
	  customer = Stripe::Customer.create(
	    :email => params[:stripeEmail],
	    :source  => params[:stripeToken]
	  )

		@transaction = Transaction.new(user_id: session[:user_id], total: (@amount/100).to_f, transaction_code: "#AT-#{session[:user_id]}0#{Date.today.to_s}")
		if @transaction.save
			@newcode = @transaction.transaction_code + @transaction.id.to_s
			@transaction.update_attribute(:transaction_code, @newcode)
			@t = Transaction.last
		else
			flash[:errors] = "Something went wrong"
			redirect_to :back
		end
	  charge = Stripe::Charge.create(
	    :customer    => customer.id,
	    :amount      => @amount,
	    :description => 'Oasis Cup Booking, Order ID #' + @transaction.id.to_s,
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
		Cart.where(user_id: @user.id).destroy_all
		if params['balancePaid']
			# @remainder = params['totalTotal'].to_f
			# @balance = params['balancePaid'].to_f
			# @balanceSwap = @remainder - @balance
			# puts @balanceSwap
			# fail
			@balancePaid = (@amount/100)
			puts @balancePaid
			@totalToPay = (@balancePaid*3)
			puts @totalToPay
			@totalToPay = (@totalToPay-@balancePaid)
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
			UserMailer.confirmation_email(@user, @transaction_type, @t).deliver_now
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
			UserMailer.confirmation_email(@user, @transaction_type, @t).deliver_now
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
			UserMailer.confirmation_email(@user, @transaction_type, @t).deliver_now
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
end

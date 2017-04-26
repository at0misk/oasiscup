class PaymentsController < ApplicationController
require 'digest/md5'
  # layout 'authorize_net'
  helper :authorize_net
  protect_from_forgery :except => :relay_response

  # GET
  # Displays a payment form.
  def payment
    @amount = 10.00
    @sim_transaction = AuthorizeNet::SIM::Transaction.new('9CPC3p3r8J', '85GL7ApYu8v533sU', @amount, :relay_url => "http://www.oasiscup.com/payments/relay_response")
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
      sim_response = AuthorizeNet::SIM::Response.new(params)
      @amount = params[:x_amount].to_i
      @user = User.find(session[:user_id])
      @team = @user.team
      @transamount = params[:x_amount].to_f/100
      @cart = Cart.where(user_id: @user.id)
      # Verifying hash is same, and response code 1 is successful
      if params[:x_MD5_Hash] == Digest::MD5.hexdigest('ABRACADABRA9CPC3p3r8J' + params[:x_trans_id] + params[:x_amount]).upcase && params[:x_response_code] == '1'
      # if sim_response.success?('9CPC3p3r8J', 'ABRACADABRA')
      # if params[:x_response_code] == '1'
        # Save Transaction
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
        @transaction_type = 0
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
        if params[:x_amount] == @total + @tax
          @transaction_type = 1
        elsif params[:x_amount] == (@total + tax)*3
          @transaction_type = 2
        elsif params[:x_amount] == @user.user_balance
          @transaction_type = 3
        end
        # Destroy Carts and Make Records
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
        # balance paid
        if @transaction_type == 1
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
        elsif @transaction_type == 2
          # paid in full
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
        elsif @transaction_type == 3
          #balance paid
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
        end
        render :text => sim_response.direct_post_reply(payments_receipt_url(:only_path => false), :include => true)
      else
        @trans_id = params[:x_trans_id]
        @amount = params[:x_amount]
        @hash = params[:x_MD5_Hash]
        @response_code = params[:x_response_code]
        @reason = params[:x_response_reason_code]
        if @response_code == 1
          @response_code = "num"
        else
          @response_code = "string"
        end
        render :layout => false
      end
  end
  
  # GET
  # Displays a receipt.
  def receipt
    @auth_code = params[:x_auth_code]
  end

end
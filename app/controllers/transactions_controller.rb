class TransactionsController < ApplicationController
	before_action :authenticate_user!

	def new
	  gon.client_token = generate_client_token
	end

	def create
		# Braintree implementation
		@user = User.find(session[:user_id])
		@amount = params['amount'].to_i
		@amount = @amount/100
		@result = Braintree::Transaction.sale(
			:amount => @amount,
			:payment_method_nonce => 'fake-valid-nonce',
            customer: {
              first_name: @user.first,
              last_name: @user.last,
              email: @user.email
            },
            options: {
              store_in_vault: true,
			  :submit_for_settlement => true
            }
		)
		if @result.success?
			@user.update_attribute(:fee_status, true)
			# 
			# Charge controller actions go here
			# 
			# session[:payed] = true
			redirect_to '/booked'
		else
			flash[:alert] = "Something went wrong while processing your transaction. Please try again!"
			gon.client_token = generate_client_token
			redirect_to :back
		end
	end

	private
	def generate_client_token
		Braintree::ClientToken.generate
	end

	# private
	# def check_cart!
	# 	if current_user.get_cart_movies.blank?
	# 		redirect_to root_url, alert: "Please add some items to your cart before processing your transaction!"
	# 	end
	# end
end

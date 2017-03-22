class TransactionsController < ApplicationController
	# before_action :check_cart!

	def new
	  gon.client_token = generate_client_token
	end

	def create
		@user = User.find(session[:user_id])
		@result = Braintree::Transaction.sale(
			:amount => '10.00',
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
			session[:payed] = true
			redirect_to '/'
		else
			flash[:alert] = "Something went wrong while processing your transaction. Please try again!"
			gon.client_token = generate_client_token
			redirect_to '/'
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

class AdminsController < ApplicationController
	def dash
		verifyAdmin
	end
	def searchUsers
		verifyAdmin
		@users = User.where('email LIKE :search OR first LIKE :search OR last LIKE :search', search: "%#{@@params}%")
	end
	def searchUsersSearch
		verifyAdmin
		@@params = params['user']
		redirect_to '/admins/searchUsers'
	end
	def searchTransactions
		verifyAdmin
		if @@code != ''
			@transaction = Transaction.find_by(transaction_code: "#{@@code}")
			@user = User.find(@transaction.user_id)
		else
			flash[:errors] = "Must be a valid confirmation number"
			redirect_to :back
		end
	end
	def searchTransactionsSearch
		verifyAdmin
		if params['code']
			@@code = params['code']
			redirect_to '/admins/searchTransactions'
		else
			flash[:errors] = "Must be a valid confirmation number"
			redirect_to :back
		end
	end
	def verifyAdmin
		if !session[:user_id]
			redirect_to '/'
		else
			@user = User.find(session[:user_id])
			if !@user.permod
				redirect_to '/'
			end
		end
	end
end

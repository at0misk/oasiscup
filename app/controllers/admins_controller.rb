class AdminsController < ApplicationController
	def dash
		@user = User.find(session[:user_id])
		if !@user.permod
			redirect_to '/'
		end
	end
	def searchUsers
		@users = User.where('email LIKE :search OR first LIKE :search OR last LIKE :search', search: "%#{@@params}%")
	end
	def searchUsersSearch
		@@params = params['user']
		redirect_to '/admins/searchUsers'
	end
	def searchTransactions
		if @@code != ''
			@transaction = Transaction.find_by(transaction_code: "#{@@code}")
			@user = User.find(@transaction.user_id)
		else
			flash[:errors] = "Must be a valid confirmation number"
			redirect_to :back
		end
	end
	def searchTransactionsSearch
		if params['code']
			@@code = params['code']
			redirect_to '/admins/searchTransactions'
		else
			flash[:errors] = "Must be a valid confirmation number"
			redirect_to :back
		end
	end
end

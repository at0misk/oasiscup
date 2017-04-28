class AdminsController < ApplicationController
	@@params = ''
	@@code = ''
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
	def searchTeamName
		verifyAdmin
		@@params = params['name']
		redirect_to '/admins/searchTeamsNameView'
	end
	def searchTeamsNameView
		verifyAdmin
		@teams = Team.where('name LIKE :search', search: "%#{@@params}%")
	end
	def searchTeamConf
		verifyAdmin
		@@params = params['conf']
		redirect_to '/admins/searchTeamsConfView'
	end
	def searchTeamsConfView
		verifyAdmin
		@teams = Team.where('conf_num LIKE :search', search: "%#{@@params}%")
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

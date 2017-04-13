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
end

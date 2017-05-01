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
	def mailEndOfDay
		verifyAdmin
		@user = User.find(session[:user_id])
		UserMailer.end_of_day_email(@user).deliver_now
		redirect_to :back
	end
	def endOfDay
		verifyAdmin
		@users = User.where("created_at >= ?", Time.zone.now.beginning_of_day)
		@teams = Team.where("created_at >= ?", Time.zone.now.beginning_of_day)
		@booked_rooms = Book.where("created_at >= ?", Time.zone.now.beginning_of_day)
		@transactions = Transaction.where("created_at >= ?", Time.zone.now.beginning_of_day)
		@guests = Guest.where("created_at >= ?", Time.zone.now.beginning_of_day)
		@hotels = Hotel.all
		@emptiedHotels = []
			@hotels.each do |val|
				if val.rooms.length == 0 && !val.shelved
					@emptiedHotels << val
				end
			end
	end
	def yesterday
		verifyAdmin
		@users = User.where("DATE(created_at) = ?", Date.today-1)
		@teams = Team.where("DATE(created_at) = ?", Date.today-1)
		@booked_rooms = Book.where("DATE(created_at) = ?", Date.today-1)
		@transactions = Transaction.where("DATE(created_at) = ?", Date.today-1)
		@guests = Guest.where("DATE(created_at) = ?", Date.today-1)
		@hotels = Hotel.all
		@emptiedHotels = []
			@hotels.each do |val|
				if val.rooms.length == 0 && !val.shelved
					@emptiedHotels << val
				end
			end
	end
	def monday
		verifyAdmin
		@users = User.where('created_at BETWEEN ? AND ?', Date.today-3, Date.today)
		@teams = Team.where('created_at BETWEEN ? AND ?', Date.today-3, Date.today)
		@booked_rooms = Book.where('created_at BETWEEN ? AND ?', Date.today-3, Date.today)
		@transactions = Transaction.where('created_at BETWEEN ? AND ?', Date.today-3, Date.today)
		@guests = Guest.where('created_at BETWEEN ? AND ?', Date.today-3, Date.today)
		@hotels = Hotel.all
		@emptiedHotels = []
			@hotels.each do |val|
				if val.rooms.length == 0 && !val.shelved
					@emptiedHotels << val
				end
			end
	end
	def one_week_warning
		@userArr = []
		@users = User.where(user_balance: !nil)
		@users.each do |val|
			val.books.each do |book|
				if book.created_at == Date.today - 7
					@userArr << val
				end
			end
		end
		@books = Book.where('created_at = ?', Date.today-7)
		@narrow = @books.where(paid_status: false)
	end
end

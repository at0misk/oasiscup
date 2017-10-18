class AdminsController < ApplicationController
	@@params = ''
	@@code = ''
	def dash
		verifyAdmin
		@hotels = Hotel.all
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
		@admins = User.where(team_id: 18)
		@admins.each do |val|
			UserMailer.end_of_day_email(@user, val).deliver_now
		end
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
		verifyAdmin
		@userArr = []
		@users = User.where(down_payment_status: false).where("user_balance > ?", 0)
		@users.each do |val|
			val.books.each do |book|
				if book.created_at == Date.today - 10
					@userArr << val
				end
			end
		end
		@userArr.each do |val|
			@email = val.email
			UserMailer.one_week_warning(val).deliver_now
		end
		UserMailer.one_week_admin(@userArr).deliver_now
		redirect_to :back
	end
	def allUsers
		verifyAdmin
		@users = User.all.order(created_at: :desc).paginate(:page => params[:page])
	end
	def balance
		verifyAdmin
		@users = User.where("user_balance > ?", 0)
	end
	def no_down_payment
		verifyAdmin
		@users = User.where(down_payment_status: false).order(created_at: :desc).paginate(:page => params[:page])
	end
	def mail_user_report
		verifyAdmin
		@user_mail = User.find(session[:user_id])
		@user_report = User.find(params['id'])
		UserMailer.user_report(@user_mail, @user_report).deliver_now
		flash[:mailed] = true
		redirect_to :back
	end
	def hotel_mailed
		verifyAdmin
		@user = User.find(params['id'])
		@user.update_attribute(:email_hotel_conf, true)
		# fail
		@user.save
		redirect_to :back
	end
	def hotel_not_mailed
		verifyAdmin
		@user = User.find(params['id'])
		@user.update_attribute(:email_hotel_conf, false)
		@user.save
		redirect_to :back
	end
	def ten_days
		verifyAdmin
		@users = []
		@users_found = User.where(down_payment_status: false).where("user_balance > ?", 0)
		@users_found.each do |val|
			val.books.each do |book|
				if book.created_at <= Date.today - 10 || book.updated_at <= Date.today - 10
					@users << val
				end
			end
		end
		@users = @users.uniq
	end
	def note
		@book = Book.find(params['id'])
		@book.note = params['note']
		@book.save
		redirect_back(fallback_location: '/admins/dash')
	end
	def books_by_hotel
		@books = Book.where(hotel_id: params['hotel_id']).paginate(:page => params[:page])
	end
end

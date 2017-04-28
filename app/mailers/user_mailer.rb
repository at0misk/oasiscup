class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'
 
  def welcome_email(user)
    @user = user
    @url  = 'http://www.oasiscup.com'
    mail(to: @user.email, subject: 'Welcome to oasiscup.com!')
    mail(to: 'oasiscuppalmdesert@gmail.com', subject: 'Welcome to oasiscup.com!')
  end
  def manifest_email(user)
    @user = user
	@total = 0
	@user.books.each do |val|
		@total += val.price
	end
    @url  = 'http://example.com/login'
    mail(to: 'ktp925@gmail.com', subject: 'Manifest Email for ' +  @user.first + " " + @user.last)
  end

  def confirmation_email(user, transaction_type, transaction, admin)
    @user = user
    @team = @user.team
    @total = 0
    @transaction = transaction
    @admin = admin
    if @admin
      @email = 'oasiscuppalmdesert@gmail.com'
    else
      @email = @user.email
    end
    @user.books.each do |val|
      @total += val.price
    end
    @transaction_type = transaction_type
    @url  = 'http://example.com/login'
        @booked_rooms = Book.where(team_id: @team.id)
    @user_rooms = Book.where(user_id: @user.id)
    @total = 0
    @tax = 0
      @booked_rooms.each do |val|
      @roomTax = val.hotel.tax
    @tax += @roomTax * val.price
        @total += val.price
      end
    @total_user = 0
    @tax_user = 0
      @user_rooms.each do |val|
        @userRoomTax = val.hotel.tax
        @tax_user += @userRoomTax * val.price
        @total_user += val.price
      end
    mail(to: "#{@email}", subject: 'Booking Confirmation for ' +  @user.first + " " + @user.last)
  end
  def create_and_deliver_password_change(user, random_password)
    @user = user
    @random_password = random_password
    mail(to: "#{@user.email}", subject: 'Password Recovery')
  end
  def payment_pending(user)
    @user = user
      @team = @user.team
      @booked_rooms = Book.where(team_id: @team.id)
      @user_rooms = Book.where(user_id: @user.id)
      @total = 0
      @tax = 0
        @booked_rooms.each do |val|
        @roomTax = val.hotel.tax
      @tax += @roomTax * val.price
          @total += val.price
        end
      @total_user = 0
      @tax_user = 0
        @user_rooms.each do |val|
          @userRoomTax = val.hotel.tax
          @tax_user += @userRoomTax * val.price
          @total_user += val.price
        end
    mail(to: "#{@user.email}", subject: 'Oasis Cup Palm Desert Tournament Booking')
    def admin_payment_pending(user)
    @user = user
      @team = @user.team
      @booked_rooms = Book.where(team_id: @team.id)
      @user_rooms = Book.where(user_id: @user.id)
      @total = 0
      @tax = 0
        @booked_rooms.each do |val|
        @roomTax = val.hotel.tax
      @tax += @roomTax * val.price
          @total += val.price
        end
      @total_user = 0
      @tax_user = 0
        @user_rooms.each do |val|
          @userRoomTax = val.hotel.tax
          @tax_user += @userRoomTax * val.price
          @total_user += val.price
        end
    mail(to: "ktp925@gmail.com", subject: "Booking Form - #{@user.first} #{@user.last}" )
    end
  end
end

class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'
 
  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
  def manifest_email(user)
    @user = user
	@total = 0
	@user.books.each do |val|
		@total += val.price
	end
    @url  = 'http://example.com/login'
    mail(to: 'ktp925@gmail.com', subject: 'Manifest Email for ' +  @user.first + @user.last)
  end
end

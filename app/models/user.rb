class User < ApplicationRecord
	validates :first, :last, :email, :team, :password, presence: true
	has_secure_password
	email_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
	validates :email, :uniqueness => true, :format => { :with => email_regex }
	validates_uniqueness_of :email, :case_sensitive => false
	has_many :books
	has_many :reservations
	has_many :carts
	has_many :guests
end

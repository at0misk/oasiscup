class User < ApplicationRecord
	has_secure_password
	email_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
	validates :first, :last, :email, :password, presence: true
	validates :email, :uniqueness => true, :format => { :with => email_regex }
	validates_uniqueness_of :email, :case_sensitive => false
	has_many :books
end

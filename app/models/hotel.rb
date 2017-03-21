class Hotel < ApplicationRecord
	has_many :rooms
	has_many :books
	has_many :carts
end

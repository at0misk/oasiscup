class Team < ApplicationRecord
	has_many :users
	has_many :guests
	has_many :books
end

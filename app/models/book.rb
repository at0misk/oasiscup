class Book < ApplicationRecord
  belongs_to :hotel
  belongs_to :user
end

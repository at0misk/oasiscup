class Room < ApplicationRecord
  paginates_per 7
  belongs_to :hotel
end

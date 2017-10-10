class Cart < ApplicationRecord
  belongs_to :hotel
  belongs_to :user
  # validates_uniqueness_of :number, :scope => [:hotel_id]
end

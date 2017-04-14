class Tbook < ApplicationRecord
  belongs_to :hotel
  belongs_to :user
  belongs_to :team
end

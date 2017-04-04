class Guest < ApplicationRecord
  belongs_to :user
  belongs_to :team
  validates_uniqueness_of :compoundname, :scope => [:user_id]
  validates :first, :last, :guest_type, presence: true
end

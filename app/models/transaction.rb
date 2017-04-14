class Transaction < ApplicationRecord
  belongs_to :user
  has_many :books
  has_many :tbooks
end

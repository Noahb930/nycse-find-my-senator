class Senator < ApplicationRecord
  has_many :votes
  has_many :bills, through: :votes
end

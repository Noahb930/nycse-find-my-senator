class Bill < ApplicationRecord
  has_many :votes
  has_many :senators, through: :votes
end

class Senator < ApplicationRecord
  has_many :votes
  has_many :bills, through: :votes
  has_many :donations
  has_many :lobbyists, through: :donations
end

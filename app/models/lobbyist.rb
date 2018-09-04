class Lobbyist < ApplicationRecord
  has_many :donations
  has_many :senators, through: :donations
end

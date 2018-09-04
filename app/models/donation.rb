class Donation < ApplicationRecord
  belongs_to :lobbyist
  belongs_to :senator
end

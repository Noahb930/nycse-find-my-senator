class Donation < ApplicationRecord
  belongs_to :lobbyist
  belongs_to :representative
end

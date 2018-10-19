class Bill < ApplicationRecord
  has_many :votes
  has_many :representatives, through: :votes
end

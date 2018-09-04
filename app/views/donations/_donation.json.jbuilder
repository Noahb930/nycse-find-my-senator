json.extract! donation, :id, :value, :lobbyist_id, :senator_id, :created_at, :updated_at
json.url donation_url(donation, format: :json)

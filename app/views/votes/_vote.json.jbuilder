json.extract! vote, :id, :position, :bill_id, :representative_id, :created_at, :updated_at
json.url vote_url(vote, format: :json)

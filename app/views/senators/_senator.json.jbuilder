json.extract! senator, :id, :name, :email, :party, :beliefs, :rating, :img, :district, :url, :created_at, :updated_at
json.url senator_url(senator, format: :json)

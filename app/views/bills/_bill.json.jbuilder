json.extract! bill, :id, :number, :status, :session, :summary, :created_at, :updated_at
json.url bill_url(bill, format: :json)

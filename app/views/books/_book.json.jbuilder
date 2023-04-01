json.extract! book, :id, :user_id, :title, :body, :created_at, :updated_at
json.url book_url(book, format: :json)

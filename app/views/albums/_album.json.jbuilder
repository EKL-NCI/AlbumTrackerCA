json.extract! album, :id, :title, :artist, :release_year, :genre, :rating, :availability, :created_at, :updated_at
json.url album_url(album, format: :json)

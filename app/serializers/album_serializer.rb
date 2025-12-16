class AlbumSerializer
  include Rails.application.routes.url_helpers

  HOST = ENV.fetch("HOST_URL", "https://albumtrackerca.onrender.com")

  def initialize(album)
    @album = album
  end

  def as_json(*)
    {
      id: @album.id,
      title: @album.title,
      artist: @album.artist,
      release_year: @album.release_year,
      genre: @album.genre,
      rating: @album.rating,
      availability: @album.availability,
      star_rating: star_rating,
      cover_image_url: cover_image_url,
      cover_thumbnail_url: cover_thumbnail_url
    }
  end

  private

  def star_rating
    "★" * @album.rating.to_i
  end

  def cover_image_url
    return nil unless @album.cover_image.attached?
    rails_blob_url(@album.cover_image, host: HOST)
  end

  def cover_thumbnail_url
    return nil unless @album.cover_image.attached?
    rails_representation_url(
      @album.cover_image.variant(resize_to_limit: [100, 100]).processed,
      host: HOST
    )
  rescue
    cover_image_url
  end
end

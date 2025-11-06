module AlbumsHelper
  def star_rating(rating)
    rating = rating.to_i.clamp(0, 5)
    full_stars = "&#9733;" * rating
    empty_stars = "&#9734;" * (5 - rating)
    (full_stars + empty_stars).html_safe
  end

  def display_cover(album, size: "100x100")
    width, height = size.split("x").map(&:to_i)
    if album.cover_image.attached?
      image_tag album.cover_image.variant(resize_to_fill: [width, height]).processed,
                class: "rounded shadow-sm", alt: album.title
    else
      image_tag "generic-album.png",
                class: "rounded shadow-sm",
                style: "width: #{width}px; height: #{height}px; object-fit: cover;",
                alt: "Generic Album Cover"
    end
  end
end

module AlbumsHelper
  def star_rating(rating)
    rating = rating.to_i.clamp(0, 5)
    full_stars = "&#9733;" * rating
    empty_stars = "&#9734;" * (5 - rating)
    (full_stars + empty_stars).html_safe
  end

  def display_cover(album, size: nil)
    if album.cover_image.attached?
      if size
        width, height = size.split("x").map(&:to_i)
        image_tag album.cover_image.variant(resize_to_limit: [ width, height ]), class: "img-thumbnail", alt: album.title
      else
        image_tag album.cover_image, class: "img-fluid rounded shadow-sm", alt: album.title, style: "max-height: 300px;"
      end
    else
      if size
        width, height = size.split("x").map(&:to_i)
        image_tag "generic-album.png", class: "img-thumbnail", style: "width: #{width}px; height: #{height}px;", alt: "Generic Album Cover"
      else
        image_tag "generic-album.png", class: "img-fluid rounded shadow-sm", alt: "Generic Album Cover", style: "max-height: 300px;"
      end
    end
  end
end

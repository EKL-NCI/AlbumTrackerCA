module AlbumsHelper
  def star_rating(rating)
    rating = rating.to_i.clamp(0, 5)
    full_stars = "&#9733;" * rating
    empty_stars = "&#9734;" * (5 - rating)
    (full_stars + empty_stars).html_safe
  end
end

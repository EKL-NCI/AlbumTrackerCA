module AlbumsHelper
    def star_rating(rating)
    full_stars = "&#9733;" * rating
    empty_stars = "&#9734;" * (5 - rating)
    full_stars + empty_stars
  end
end
